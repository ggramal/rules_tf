"""
This module contains tf providers.
"""

TerraformPlanInfo = provider(
    doc = "Information about Terraform plan.",
    fields = {
        "plan": "the plan file",
    },
)

TerraformInitInfo = provider(
    doc = "Information about Terraform init.",
    fields = {
        "init_archive": "File of archived .terraform dir",
    },
)
