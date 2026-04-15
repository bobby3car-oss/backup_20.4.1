---
applyTo: "firestore.rules"
---

# Firestore Security Rules

## Key Patterns
- Patient data: Owner read/write, linked doctors read-only on specific fields
- Doctor data: Doctor owner + their staff (permission-based)
- Organisation data: Org owner + org staff
- Admin: Hardcoded admin UIDs in rules
- Collection group queries indexed for `patients/{id}/invites`

## Reference
Read `/memories/repo/firestore_collectiongroup_rules.md` for full rule patterns.
Read `/memories/repo/backend_enforcement_audit.md` for security audit results.
