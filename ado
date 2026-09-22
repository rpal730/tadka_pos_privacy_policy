# azure-pipelines.yml
# Pipeline: multi-repo-build
# Builds any subset of repos a, b, c, d. Manual trigger only.

name: $(Date:yyyyMMdd).$(Rev:r)     # produces run numbers like 20260922.1

trigger: none                        # no CI trigger; run manually or on a schedule
pr: none

# ---------------------------------------------------------------------------
# Runtime parameter: this is what renders in the "Run pipeline" panel.
# Delete lines from the list at queue time to build only some repos.
# ---------------------------------------------------------------------------
parameters:
  - name: repos
    displayName: Repos to build
    type: object
    default:
      - a
      - b
      - c
      - d

# ---------------------------------------------------------------------------
# Every repo must be declared once here. This part is not dynamic.
# The alias (repository: a) is what the parameter list and checkout refer to.
# ---------------------------------------------------------------------------
resources:
  repositories:
    - repository: a
      type: git
      name: MyProject/repo-a
      ref: refs/heads/main

    - repository: b
      type: git
      name: MyProject/repo-b
      ref: refs/heads/main

    - repository: c
      type: git
      name: MyProject/repo-c
      ref: refs/heads/main

    - repository: d
      type: git
      name: MyProject/repo-d
      ref: refs/heads/main

pool:
  vmImage: ubuntu-latest
  # For your on-prem agent instead:
  # name: MyOnPremPool

# ---------------------------------------------------------------------------
# One job per selected repo. ${{ each }} expands at compile time, so a repo
# left out of the parameter list produces no job at all.
# ---------------------------------------------------------------------------
stages:
  - stage: Build
    displayName: Build
    jobs:
      - ${{ each repo in parameters.repos }}:
        - job: Build_${{ repo }}
          displayName: Build_${{ repo }}
          timeoutInMinutes: 30
          workspace:
            clean: outputs
          steps:
            - checkout: ${{ repo }}
              clean: true
              fetchDepth: 1
              displayName: Checkout ${{ repo }}

            - script: |
                echo "Building ${{ repo }}..."
                ls -la
                # replace with your real build:
                #   dotnet build --configuration Release
                #   npm ci && npm run build
                #   mvn -B package
              displayName: Build
              workingDirectory: $(Build.SourcesDirectory)
