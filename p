 steps: 
      - name: Checkout the dev branch 
        uses: actions/checkout@v4 
        with: 
          ref: dev 
          fetch-depth: 0 

      - name: Fetch all tags 
        run: git fetch --tags 

      - name: Get the latest tag 
        id: get_tag 
        run: | 
          VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
          echo "VERSION=$VERSION" >> $GITHUB_ENV

      - name: Print the version from env 
        run: echo "Version is ${{ env.VERSION }}"

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install Python Dependencies
        run: |
          pip install --upgrade pip
          pip install -r requirements.txt

      - name: Lint the Code
        run: |
          pip install flake8
          flake8 src/main.py

      - name: Dependency Scanning
        run: |
          pip install pip-audit safety
          pip-audit > pip-audit-report.txt
          # pip freeze > requirements.txt
          # safety check -r requirements.txt --full-report > safety-report.txt

      - name: Set up Snyk CLI
        uses: snyk/actions/setup@806182742461562b67788a64410098c9d9b96adb
        env:
          SNYK_TOKEN: 9d262b22-1f2c-4069-adb9-696793789926

      - name: Snyk Code test
        run: snyk code test --sarif > snyk-code.sarif 

      - name: Install Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'

      - name: Trivy Secrets Scanning
        run: |
          trivy fs . --scanners secret --format json --output trivy-secrets.json

      - name: Trivy FS Scan
        run: |
          trivy fs . --format json --output trivy-fs-report.json

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: scan-reports
          path: |
            snyk-code.sarif
            pip-audit-report.txt
            # safety-report.txt
            trivy-secrets.json
            trivy-fs-report.json
     