# EGST - Enterprise Group Security Tool

EGST is a security hardening tool based on HardeningKitty that allows you to audit and secure your Windows systems according to best practices.

## Running EGST

Double-click `run.bat` in the root directory. Administrator privileges will be requested automatically.

```
========================================
  HardeningKitty - EGST Management Tool
========================================
  [1] Audit
  [2] Apply Rules
  [3] Restore
  [0] Exit
========================================
```

### [1] Audit Mode

To assess the current security configuration of your system without making any changes, select option **[1]**.

This will:
- Generate a comprehensive security assessment report
- Create a backup of your current system configuration
- Evaluate compliance against security best practices
- Identify security vulnerabilities and recommend remediation steps

Output files are saved in the `EGST/` folder:
- `hardeningkitty_report_*.csv` — Audit report
- `hardeningkitty_backup_*.csv` — Settings backup (can be used for restore)
- `hardeningkitty_log_*.log` — Execution log

### [2] Apply Rules

To apply recommended security settings automatically, select option **[2]**.

This will:
- Prompt you whether to create a system restore point before making changes
- Apply security best practices to your system
- Harden configurations according to industry standards
- Implement recommended registry changes and security settings

### [3] Restore

To revert changes made during a previous remediation, select option **[3]**.

You will be prompted to select a backup file generated during a previous audit to restore your system settings.

## Important Notes

- Always run these scripts with administrative privileges
- Review the audit report before applying any changes
- Some security changes may affect application compatibility
- The scripts will generate log files documenting all actions taken

For detailed information about the specific security settings applied, refer to `EGST/EGST_windows_rulset.csv`.

## Repository Structure

```
/
├── run.bat                      # Entry point
├── hardeningkitty/              # HardeningKitty engine (git submodule)
└── EGST/
    ├── main.ps1                 # Menu script
    ├── EGST_windows_rulset.csv  # EGST custom security policies
    └── hardeningkitty_*         # Audit reports, backups, logs
```

## Updating the HardeningKitty Engine

```bash
git submodule update --remote hardeningkitty
git add hardeningkitty
git commit -m "chore: update hardeningkitty"
```

## Cloning with Submodule

```bash
git clone --recurse-submodules <repo-url>
# or after cloning
git submodule update --init
```
