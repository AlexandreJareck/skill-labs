[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('route', 'profile', 'transition', 'failure', 'validate', 'acceptance')]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$Value1,

    [Parameter(Position = 2)]
    [string]$Value2,

    [switch]$CorrectsBehavior,

    [switch]$Background,

    [switch]$Database,

    [switch]$SecuritySensitive,

    [ValidateRange(1, 100)]
    [int]$AttemptLimit = 3
)

$Routes = @{
    feature     = @('intake', 'requirements', 'architecture', 'tasks', 'implementation', 'testing', 'validation', 'homologation', 'documentation')
    improvement = @('intake', 'requirements', 'architecture', 'tasks', 'implementation', 'testing', 'validation', 'homologation', 'documentation')
    bug         = @('intake', 'triage', 'investigation', 'root-cause', 'architecture', 'tasks', 'correction', 'testing', 'validation', 'homologation', 'documentation')
    correction  = @('intake', 'triage', 'investigation', 'root-cause', 'architecture', 'tasks', 'correction', 'testing', 'validation', 'homologation', 'documentation')
    performance = @('intake', 'metric-definition', 'baseline', 'profiling', 'bottleneck-or-cause', 'architecture', 'tasks', 'optimization', 'comparison', 'functional-testing', 'homologation', 'documentation')
    unknown     = @('intake')
}

$CoreMicrophases = @(
    'understanding', 'planning', 'implementation', 'technical-review',
    'correction-loop', 'testing', 'final-review', 'commit',
    'pull-request', 'human-code-review'
)

$Transitions = @{
    draft         = @('investigating', 'in_review', 'blocked', 'invalidated')
    investigating = @('in_review', 'blocked', 'inconclusive', 'invalidated')
    in_review     = @('approved', 'draft', 'investigating', 'blocked', 'invalidated')
    approved      = @('in_progress', 'invalidated')
    in_progress   = @('completed', 'blocked', 'in_review', 'invalidated')
    blocked       = @('draft', 'investigating', 'in_progress', 'invalidated')
    inconclusive  = @('investigating', 'in_review', 'invalidated')
    completed     = @('invalidated')
    invalidated   = @('draft', 'investigating')
}

$TypeStates = @{
    source                = @('completed', 'invalidated')
    demand                = @('draft', 'in_review', 'approved', 'blocked', 'invalidated')
    evidence              = @('draft', 'investigating', 'in_review', 'completed', 'inconclusive', 'invalidated')
    hypothesis            = @('draft', 'investigating', 'in_review', 'completed', 'inconclusive', 'invalidated')
    root_cause            = @('draft', 'investigating', 'in_review', 'approved', 'inconclusive', 'invalidated')
    requirement           = @('draft', 'in_review', 'approved', 'blocked', 'invalidated')
    architecture_decision = @('draft', 'in_review', 'approved', 'blocked', 'invalidated')
    task                  = @('draft', 'in_review', 'approved', 'in_progress', 'blocked', 'completed', 'invalidated')
    implementation        = @('draft', 'in_progress', 'blocked', 'completed', 'invalidated')
    validation            = @('draft', 'in_progress', 'blocked', 'completed', 'inconclusive', 'invalidated')
    documentation         = @('draft', 'in_progress', 'in_review', 'completed', 'invalidated')
}

$RequiredFields = @('id', 'artifact_type', 'state', 'parents', 'depends_on', 'related', 'confidence', 'invalidated_by', 'updated_at')
$ListFields = @('parents', 'depends_on', 'related', 'invalidated_by')
$ConfidenceValues = @('low', 'medium', 'high', 'not_applicable')

function Get-WorkflowRoute {
    param(
        [Parameter(Mandatory)]
        [string]$RequestType,
        [switch]$ImprovementCorrectsBehavior
    )

    $normalized = $RequestType.ToLowerInvariant()
    if (-not $Routes.ContainsKey($normalized)) {
        throw "Unknown type: $RequestType"
    }
    if ($normalized -eq 'improvement' -and $ImprovementCorrectsBehavior) {
        return @($Routes.correction)
    }
    return @($Routes[$normalized])
}

function Get-DeliveryMicrophases {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('simple', 'standard', 'complex', 'critical')]
        [string]$Profile,
        [switch]$HasBackground,
        [switch]$HasDatabase,
        [switch]$IsSecuritySensitive
    )

    $result = [Collections.Generic.List[string]]::new()
    foreach ($phase in @('understanding', 'planning')) { $result.Add($phase) }

    if ($Profile -eq 'complex') { $result.Add('resilience-analysis') }
    if ($Profile -eq 'critical') {
        $result.Add('threat-model')
        $result.Add('security-design-review')
    }
    if ($HasBackground) {
        foreach ($phase in @('progress-design', 'idempotency-retry-replay')) {
            if (-not $result.Contains($phase)) { $result.Add($phase) }
        }
    }
    if ($HasDatabase) {
        $result.Add('database-change-plan')
    }
    if ($IsSecuritySensitive) {
        foreach ($phase in @('threat-model', 'security-design-review')) {
            if (-not $result.Contains($phase)) { $result.Add($phase) }
        }
    }

    foreach ($phase in @('implementation', 'technical-review', 'correction-loop', 'testing')) { $result.Add($phase) }

    if ($Profile -in @('standard', 'complex', 'critical')) { $result.Add('integration-testing') }
    if ($Profile -in @('complex', 'critical')) {
        $result.Add('end-to-end-testing')
        $result.Add('operational-readiness')
        $result.Add('recovery-planning')
    }
    if ($Profile -eq 'critical') {
        $result.Add('security-verification')
        $result.Add('specialist-review')
        $result.Add('recovery-test')
        $result.Add('human-risk-approval')
    }
    if ($HasBackground) {
        foreach ($phase in @('progress-tracking', 'background-observability')) {
            if (-not $result.Contains($phase)) { $result.Add($phase) }
        }
    }
    if ($HasDatabase) {
        foreach ($phase in @('migration-validation', 'data-reconciliation')) {
            if (-not $result.Contains($phase)) { $result.Add($phase) }
        }
    }
    if ($IsSecuritySensitive) {
        foreach ($phase in @('security-verification', 'specialist-review')) {
            if (-not $result.Contains($phase)) { $result.Add($phase) }
        }
    }
    if ($Profile -in @('standard', 'complex', 'critical')) {
        $result.Add('qa-handoff')
        $result.Add('rollout-rollback-check')
    }

    foreach ($phase in @('final-review', 'commit', 'pull-request', 'human-code-review')) { $result.Add($phase) }
    return @($result)
}

function Test-WorkflowTransition {
    param(
        [Parameter(Mandatory)][string]$Current,
        [Parameter(Mandatory)][string]$Next
    )

    return $Transitions.ContainsKey($Current) -and $Transitions[$Current] -contains $Next
}

function Get-FailureDisposition {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('transient', 'product', 'test_defect', 'flaky', 'environment', 'ambiguous')]
        [string]$Category,
        [Parameter(Mandatory)][ValidateRange(1, 100)][int]$Attempt,
        [ValidateRange(1, 100)][int]$Limit = 3
    )

    if ($Attempt -ge $Limit) { return 'blocked' }
    switch ($Category) {
        'transient'   { return 'retry_with_backoff' }
        'product'     { return 'rework' }
        'test_defect' { return 'review_test_and_requirement' }
        'flaky'       { return 'investigate_flakiness' }
        'environment' { return 'blocked' }
        'ambiguous'   { return 'human_review' }
    }
}

function Read-ArtifactFrontmatter {
    param([Parameter(Mandatory)][System.IO.FileInfo]$Path)

    $content = Get-Content -LiteralPath $Path.FullName -Raw -Encoding UTF8
    $match = [regex]::Match($content, '\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\z)', [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) {
        throw 'missing frontmatter'
    }

    $data = @{}
    foreach ($line in ($match.Groups[1].Value -split '\r?\n')) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith('#')) { continue }
        $separator = $line.IndexOf(':')
        if ($separator -lt 1) { throw "invalid frontmatter line: $line" }
        $key = $line.Substring(0, $separator).Trim()
        $raw = $line.Substring($separator + 1).Trim()
        if ($ListFields -contains $key) {
            try { $value = @($raw | ConvertFrom-Json -ErrorAction Stop) }
            catch { throw "$key must be an inline JSON list" }
            if (@($value | Where-Object { $_ -isnot [string] }).Count -gt 0) {
                throw "$key must contain only strings"
            }
            $data[$key] = $value
        }
        else {
            $data[$key] = $raw.Trim('"', "'")
        }
    }
    return $data
}

function Get-InvalidatedDependents {
    param(
        [Parameter(Mandatory)][string[]]$Changed,
        [Parameter(Mandatory)][hashtable]$Dependencies
    )

    $reverse = @{}
    foreach ($artifact in $Dependencies.Keys) {
        foreach ($dependency in @($Dependencies[$artifact])) {
            if (-not $reverse.ContainsKey($dependency)) { $reverse[$dependency] = [Collections.Generic.HashSet[string]]::new() }
            [void]$reverse[$dependency].Add($artifact)
        }
    }
    $changedSet = [Collections.Generic.HashSet[string]]::new([string[]]$Changed)
    $affected = [Collections.Generic.HashSet[string]]::new()
    $queue = [Collections.Generic.Queue[string]]::new()
    foreach ($item in $Changed) { $queue.Enqueue($item) }
    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        if (-not $reverse.ContainsKey($current)) { continue }
        foreach ($dependent in $reverse[$current]) {
            if (-not $changedSet.Contains($dependent) -and $affected.Add($dependent)) {
                $queue.Enqueue($dependent)
            }
        }
    }
    return @($affected | Sort-Object)
}

function Test-DependencyCycle {
    param([Parameter(Mandatory)][hashtable]$Dependencies)

    $indegree = @{}
    $dependents = @{}
    foreach ($node in $Dependencies.Keys) { $indegree[$node] = 0 }
    foreach ($node in $Dependencies.Keys) {
        foreach ($dependency in @($Dependencies[$node])) {
            if (-not $Dependencies.ContainsKey($dependency)) { continue }
            $indegree[$node]++
            if (-not $dependents.ContainsKey($dependency)) { $dependents[$dependency] = @() }
            $dependents[$dependency] += $node
        }
    }
    $queue = [Collections.Generic.Queue[string]]::new()
    foreach ($node in $indegree.Keys) { if ($indegree[$node] -eq 0) { $queue.Enqueue($node) } }
    $visited = 0
    while ($queue.Count -gt 0) {
        $node = $queue.Dequeue()
        $visited++
        if (-not $dependents.ContainsKey($node)) { continue }
        foreach ($dependent in @($dependents[$node])) {
            $indegree[$dependent]--
            if ($indegree[$dependent] -eq 0) { $queue.Enqueue($dependent) }
        }
    }
    return $visited -ne $Dependencies.Count
}

function Test-WorkflowDirectory {
    param([Parameter(Mandatory)][string]$RequestDirectory)

    $errors = [Collections.Generic.List[string]]::new()
    if (-not (Test-Path -LiteralPath $RequestDirectory -PathType Container)) {
        return @("directory not found: $RequestDirectory")
    }
    $paths = @(Get-ChildItem -LiteralPath $RequestDirectory -Filter '*.md' -File -Recurse | Sort-Object FullName)
    if ($paths.Count -eq 0) { return @("no Markdown artifact found in $RequestDirectory") }

    $records = @{}
    foreach ($path in $paths) {
        try { $data = Read-ArtifactFrontmatter -Path $path }
        catch { $errors.Add("$($path.FullName): $($_.Exception.Message)"); continue }
        $missing = @($RequiredFields | Where-Object { -not $data.ContainsKey($_) })
        if ($missing.Count -gt 0) {
            $errors.Add("$($path.FullName): missing fields: $($missing -join ', ')")
            continue
        }
        $id = [string]$data.id
        if ($records.ContainsKey($id)) { $errors.Add("$($path.FullName): id duplicado $id") }
        else { $records[$id] = @{ Path = $path; Data = $data } }
        $type = [string]$data.artifact_type
        $state = [string]$data.state
        if (-not $TypeStates.ContainsKey($type)) { $errors.Add("$($path.FullName): invalid artifact_type $type") }
        elseif ($TypeStates[$type] -notcontains $state) { $errors.Add("$($path.FullName): invalid state $state for $type") }
        if ($ConfidenceValues -notcontains [string]$data.confidence) { $errors.Add("$($path.FullName): invalid confidence $($data.confidence)") }
    }

    $dependencies = @{}
    foreach ($id in $records.Keys) {
        $record = $records[$id]
        $dependencies[$id] = @($record.Data.depends_on)
        foreach ($field in $ListFields) {
            foreach ($target in @($record.Data[$field])) {
                if (-not $records.ContainsKey($target)) { $errors.Add("$($record.Path.FullName): broken reference in ${field}: $target") }
            }
        }
        if ($record.Data.state -eq 'invalidated' -and @($record.Data.invalidated_by).Count -eq 0) {
            $errors.Add("$($record.Path.FullName): invalidated artifact without invalidated_by")
        }
    }
    if (Test-DependencyCycle -Dependencies $dependencies) { $errors.Add('dependency cycle detected') }
    return @($errors)
}

function Test-AcceptanceMatrix {
    param([Parameter(Mandatory)][string]$DeliveryArtifact)

    $errors = [Collections.Generic.List[string]]::new()
    if (-not (Test-Path -LiteralPath $DeliveryArtifact -PathType Leaf)) {
        return @("artifact not found: $DeliveryArtifact")
    }
    $lines = @(Get-Content -LiteralPath $DeliveryArtifact -Encoding UTF8)
    $start = -1
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match '^## Acceptance and regression criteria\s*$') { $start = $index + 1; break }
    }
    if ($start -lt 0) { return @('missing acceptance criteria section') }

    $criteria = 0
    $allowed = @('not_run', 'passed', 'failed', 'blocked', 'not_applicable')
    for ($index = $start; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line -match '^##\s+') { break }
        if ($line -notmatch '^\s*\|') { continue }
        $cells = @(($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
        if ($cells.Count -lt 7 -or $cells[0] -eq 'Criterion' -or $cells[0] -match '^[-:]+$') { continue }
        $criteria++
        $state = $cells[-1].ToLowerInvariant()
        if ($allowed -notcontains $state) {
            $errors.Add("criterion $($cells[0]) has invalid state: $state")
            continue
        }
        if ($state -notin @('passed', 'not_applicable')) {
            $errors.Add("criterion $($cells[0]) prevents completion: $state")
        }
        if ($state -eq 'not_applicable' -and [string]::IsNullOrWhiteSpace($cells[5])) {
            $errors.Add("criterion $($cells[0]) is not_applicable without justification in Evidence")
        }
    }
    if ($criteria -eq 0) { $errors.Add('no acceptance criterion was filled in') }
    return @($errors)
}

if (-not $Command) { return }

switch ($Command) {
    'route' {
        if (-not $Value1) { throw 'Usage: workflow.ps1 route <type> [-CorrectsBehavior]' }
        (Get-WorkflowRoute -RequestType $Value1 -ImprovementCorrectsBehavior:$CorrectsBehavior) -join ' -> '
    }
    'profile' {
        if (-not $Value1) { throw 'Usage: workflow.ps1 profile <simple|standard|complex|critical> [-Background] [-Database] [-SecuritySensitive]' }
        (Get-DeliveryMicrophases -Profile $Value1 -HasBackground:$Background -HasDatabase:$Database -IsSecuritySensitive:$SecuritySensitive) -join ' -> '
    }
    'transition' {
        if (-not $Value1 -or -not $Value2) { throw 'Usage: workflow.ps1 transition <current> <next>' }
        if (-not (Test-WorkflowTransition -Current $Value1 -Next $Value2)) {
            Write-Error "Invalid transition: $Value1 -> $Value2"
            exit 1
        }
        "Valid transition: $Value1 -> $Value2"
    }
    'failure' {
        if (-not $Value1 -or -not $Value2) { throw 'Usage: workflow.ps1 failure <category> <attempt> [-AttemptLimit N]' }
        Get-FailureDisposition -Category $Value1 -Attempt ([int]$Value2) -Limit $AttemptLimit
    }
    'validate' {
        if (-not $Value1) { throw 'Usage: workflow.ps1 validate <request-directory>' }
        $validationErrors = @(Test-WorkflowDirectory -RequestDirectory $Value1)
        if ($validationErrors.Count -gt 0) {
            foreach ($validationError in $validationErrors) { Write-Error $validationError }
            exit 1
        }
        "OK: valid artifacts in $Value1"
    }
    'acceptance' {
        if (-not $Value1) { throw 'Usage: workflow.ps1 acceptance <delivery-artifact>' }
        $acceptanceErrors = @(Test-AcceptanceMatrix -DeliveryArtifact $Value1)
        if ($acceptanceErrors.Count -gt 0) {
            foreach ($acceptanceError in $acceptanceErrors) { Write-Error $acceptanceError }
            exit 1
        }
        "OK: all acceptance criteria allow completion in $Value1"
    }
}
