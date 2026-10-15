$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'workflow.ps1')

$script:Passed = 0
function Assert-Workflow {
    param([string]$Name, [bool]$Condition)
    if (-not $Condition) { throw "FAIL: $Name" }
    $script:Passed++
    "PASS: $Name"
}

$feature = @(Get-WorkflowRoute -RequestType feature)
Assert-Workflow '01 feature in a new project' ($feature[1] -eq 'requirements' -and $feature[2] -eq 'architecture')

$improvement = @(Get-WorkflowRoute -RequestType improvement)
Assert-Workflow '02 improvement in a legacy project' ($improvement -notcontains 'investigation')
Assert-Workflow '03 feature in a legacy project preserves architecture analysis' ($feature -contains 'architecture')
Assert-Workflow '04 architecture departure occurs before tasks' ([array]::IndexOf($feature, 'architecture') -lt [array]::IndexOf($feature, 'tasks'))

$bug = @(Get-WorkflowRoute -RequestType bug)
Assert-Workflow '05 observable bug investigates before determining cause' ([array]::IndexOf($bug, 'investigation') -lt [array]::IndexOf($bug, 'root-cause'))
Assert-Workflow '06 bug without observability retains mandatory investigation' ($bug -contains 'investigation')
Assert-Workflow '07 non-reproducible intermittent issue allows inconclusive result' ($TypeStates.root_cause -contains 'inconclusive')
Assert-Workflow '08 inconclusive diagnosis is a valid state' ($TypeStates.evidence -contains 'inconclusive')

$performance = @(Get-WorkflowRoute -RequestType performance)
Assert-Workflow '09 performance measures baseline before comparison' ([array]::IndexOf($performance, 'baseline') -lt [array]::IndexOf($performance, 'comparison'))

$dependencies = @{ 'REQ-1' = @(); 'ADR-1' = @('REQ-1'); 'TSK-1' = @('ADR-1'); 'DOC-1' = @() }
$affected = @(Get-InvalidatedDependents -Changed @('REQ-1') -Dependencies $dependencies)
Assert-Workflow '10 requirement change invalidates only dependents' (($affected -join ',') -eq 'ADR-1,TSK-1')
Assert-Workflow '11 incomplete input remains in intake' (((Get-WorkflowRoute -RequestType unknown) -join ',') -eq 'intake')

$coreOrder = @('understanding', 'planning', 'implementation', 'technical-review', 'correction-loop', 'testing', 'final-review', 'commit', 'pull-request', 'human-code-review')
foreach ($profile in @('simple', 'standard', 'complex', 'critical')) {
    $microphases = @(Get-DeliveryMicrophases -Profile $profile)
    Assert-Workflow "profile $profile retains all mandatory microphases" (($coreOrder | Where-Object { $microphases -notcontains $_ }).Count -eq 0)
    Assert-Workflow "profile $profile keeps PR before human code review" ([array]::IndexOf($microphases, 'pull-request') -lt [array]::IndexOf($microphases, 'human-code-review'))
}

$conditional = @(Get-DeliveryMicrophases -Profile simple -HasBackground -HasDatabase -IsSecuritySensitive)
Assert-Workflow 'background adds progress, idempotency, and replay' ($conditional -contains 'progress-tracking' -and $conditional -contains 'idempotency-retry-replay')
Assert-Workflow 'database adds planning, validation, and reconciliation' ($conditional -contains 'database-change-plan' -and $conditional -contains 'data-reconciliation')
Assert-Workflow 'security-sensitive work adds threat and specialist review' ($conditional -contains 'threat-model' -and $conditional -contains 'specialist-review')
Assert-Workflow 'threat is analyzed before implementation' ([array]::IndexOf($conditional, 'threat-model') -lt [array]::IndexOf($conditional, 'implementation'))
Assert-Workflow 'conditional validations finish before final review' ([array]::IndexOf($conditional, 'data-reconciliation') -lt [array]::IndexOf($conditional, 'final-review'))

foreach ($routeType in @('feature', 'improvement', 'bug', 'correction', 'performance')) {
    $route = @(Get-WorkflowRoute -RequestType $routeType)
    Assert-Workflow "route $routeType tests before acceptance" (($route -contains 'testing' -or $route -contains 'functional-testing') -and [array]::IndexOf($route, 'homologation') -lt [array]::IndexOf($route, 'documentation'))
}

Assert-Workflow 'transient failure retries with a limit' ((Get-FailureDisposition -Category transient -Attempt 1) -eq 'retry_with_backoff')
Assert-Workflow 'product failure returns to implementation' ((Get-FailureDisposition -Category product -Attempt 1) -eq 'rework')
Assert-Workflow 'flakiness requires investigation' ((Get-FailureDisposition -Category flaky -Attempt 1) -eq 'investigate_flakiness')
Assert-Workflow 'attempt limit blocks the loop' ((Get-FailureDisposition -Category product -Attempt 3) -eq 'blocked')

Assert-Workflow 'valid transition' (Test-WorkflowTransition -Current in_review -Next approved)
Assert-Workflow 'invalid transition rejected' (-not (Test-WorkflowTransition -Current draft -Next completed))

$temporaryRoot = Join-Path $PSScriptRoot ".workflow-test-$PID"
try {
    [void](New-Item -ItemType Directory -Path $temporaryRoot -Force)
    $validArtifact = @'
---
id: "DEM-001"
artifact_type: "demand"
state: "draft"
parents: []
depends_on: []
related: []
confidence: "low"
invalidated_by: []
updated_at: "2026-10-14"
---
# Demanda
'@
    Set-Content -LiteralPath (Join-Path $temporaryRoot 'request.md') -Value $validArtifact -Encoding UTF8
    Assert-Workflow 'valid minimum artifact' (@(Test-WorkflowDirectory -RequestDirectory $temporaryRoot).Count -eq 0)

    $acceptedDelivery = @'
## Acceptance and regression criteria

| Criterion | Risk | Test/check | Environment | Result | Evidence | State |
|---|---|---|---|---|---|---|
| AC-001 | high | end-to-end flow | acceptance | expected behavior | report/e2e | passed |
| AC-002 | low | not applicable to backend | local | n/a | change has no visual interface | not_applicable |

## Acceptance
'@
    $failedDelivery = $acceptedDelivery.Replace('| passed |', '| failed |')
    Set-Content -LiteralPath (Join-Path $temporaryRoot 'accepted.md') -Value $acceptedDelivery -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $temporaryRoot 'failed.md') -Value $failedDelivery -Encoding UTF8
    Assert-Workflow 'complete matrix allows acceptance' (@(Test-AcceptanceMatrix -DeliveryArtifact (Join-Path $temporaryRoot 'accepted.md')).Count -eq 0)
    Assert-Workflow 'failed criterion prevents delivery' (@(Test-AcceptanceMatrix -DeliveryArtifact (Join-Path $temporaryRoot 'failed.md')).Count -gt 0)

    $first = @'
---
id: "TSK-1"
artifact_type: "task"
state: "draft"
parents: []
depends_on: ["TSK-2"]
related: ["MISSING"]
confidence: "medium"
invalidated_by: []
updated_at: "2026-10-14"
---
'@
    $second = $first.Replace('id: "TSK-1"', 'id: "TSK-2"').Replace('depends_on: ["TSK-2"]', 'depends_on: ["TSK-1"]')
    Set-Content -LiteralPath (Join-Path $temporaryRoot 'one.md') -Value $first -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $temporaryRoot 'two.md') -Value $second -Encoding UTF8
    $errors = @(Test-WorkflowDirectory -RequestDirectory $temporaryRoot)
    Assert-Workflow 'broken reference is rejected' (@($errors | Where-Object { $_ -like '*broken reference*' }).Count -gt 0)
    Assert-Workflow 'cycle is rejected' (@($errors | Where-Object { $_ -like '*dependency cycle*' }).Count -gt 0)
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
}

"OK: $script:Passed checks passed."
