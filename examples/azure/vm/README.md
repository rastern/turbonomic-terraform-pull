# Azure Compute Instance Template Resizing Example

This example utilizes a Bash script to pull a Turbonomic action template resize
for a specific compute instance, updates the Terraform variables, and optionally
applies the change immediately.

### Turbonomic APIs required
* /vmturbo/rest/markets/{market id}/actions

### Example usages

Basic usage by machine display name:

```bash
turbo.sh -s turbo.example.com -u administrator -p ***** --name myazureinstance --apply
```

Basic usage by Turbonomic internal UUID:

```bash
turbo.sh -s turbo.example.com -u administrator -p ***** --uuid B36C73A4-5BF3-44FB-A86B-1FA3C238C879
```

Alternate Terraform variable name and varibles file:

```bash
turbo.sh -s turbo.example.com -u administrator -p ***** --name myazureinstance -f instance.tfvars --var template
```
