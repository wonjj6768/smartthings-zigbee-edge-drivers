# Family Custom-Capability Catalog

`manifest.json` plus the four ordered data files in this directory are the
editable source of truth for family-specific custom capability runtime
metadata. Keep array order: package slicing and runtime metadata order depend
on it.

The catalog contains four ordered inputs:

- `attribute_overrides.json`: `[capabilityId, attributeName]`
- `numeric.json`: `[capabilityId, writable, mappingName, minimum, maximum, step, unit]`
- `enum.json`: `[capabilityId, writable, mappingName, supportedValues]`
- `text.json`: `[capabilityId, writable, mappingName, maximumLength]`

`manifest.json` fixes the namespace, format version, and expected row counts.

Numeric `null` values are intentional. Three current rows use an empty range,
and three retain only a unit; do not collapse their generated `default_range`
table to `nil`. Each enum row owns one values table shared only by that row's
`supported_values` and `default_range.allowed_values` fields.

After editing the catalog, regenerate and verify it:

```powershell
python source\tools\generate_custom_capability_catalog.py --jobs 4
python source\tools\generate_custom_capability_catalog.py --check --jobs 4
python source\tools\test_generated_custom_capability_catalog.py
```

The generator writes `source/src/generated/custom_capabilities/families.lua`.
`source/src/core/family_custom_capabilities.lua` is an API/identity compatibility
shim and must not become a second registry. The old
`analysis/custom_capability_family_matrix.json` is a historical 140-row analysis
input; it is not complete enough to regenerate the runtime catalog.
