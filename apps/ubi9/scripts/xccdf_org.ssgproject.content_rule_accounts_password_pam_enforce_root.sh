#!/bin/sh
set -e

# CCE-86356-3

(>&2 echo "Remediating: 'xccdf_org.ssgproject.content_rule_accounts_password_pam_enforce_root'")

# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

if [ -e "/etc/security/pwquality.conf" ] ; then

    LC_ALL=C sed -i "/^\s*enforce_for_root/Id" "/etc/security/pwquality.conf"
else
    touch "/etc/security/pwquality.conf"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/security/pwquality.conf"

cp "/etc/security/pwquality.conf" "/etc/security/pwquality.conf.bak"
# Insert at the end of the file
printf '%s\n' "" >> "/etc/security/pwquality.conf"
printf '%s\n' "# Per CCE-86356-3: Set enforce_for_root in /etc/security/pwquality.conf" >> "/etc/security/pwquality.conf"
printf '%s\n' "enforce_for_root" >> "/etc/security/pwquality.conf"
# Clean up after ourselves.
rm "/etc/security/pwquality.conf.bak"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi
