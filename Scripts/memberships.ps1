Import-Module ActiveDirectory

# Add users to themed groups
Add-ADGroupMember -Identity "Pandavas" -Members arjuna,bhima -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "Kauravas" -Members karna,duryodhana -ErrorAction SilentlyContinue

# Domain Admins (VERY IMPORTANT)
Add-ADGroupMember -Identity "Domain Admins" -Members krishna -ErrorAction SilentlyContinue
