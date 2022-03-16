# Scenario 2 - AKS

1. VNET for AKS (1)
2. VNET for Internal Client Network (2)
3. Peer above VNETs together - 1 & 2
4. AKS Cluster in VNET 1
   1. Azure CNI networking enabled
   2. Application Gateway (AGIC) Enabled - **Optional - Stretch Goal**
5. SQL Server & DB - Private Endpoints Enabled
6. Azure Container Registry - Private Endpoints Enabled
7. Key Vault - Private Endpoints Enabled
8. Private DNS Zones for:
   1. Azure SQL
   2. Azure Container Registry
   3. Key Vault
   4. AKS
9.  Virtual Machine in VNET 2
10. Azure Bastion in VNET 2