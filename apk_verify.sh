#!/bin/sh -eu
#
#  apk_verify -- Checks the public key and signature in APK files
#
#  Copyright (c) 2019 Samuel Lidén Borell <samuel@kodafritt.se>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#

if [ $# = 0 ] || [ "$1" = --help ]; then
    cat <<EOF
usage: $0 --manual <sha256> <apk file>...
       $0 --certname <name> <sha256> <apk file>...
       $0 --auto <apk file>...

Checks the public key and signature in APK files.

With --manual, the first argument must be the SHA-256 of the public key
The following arguments are the APK files to verify.

With --certname, you can override the filename base for the certificate
file. If not specified, this will default to CERT.RSA.

With --auto, the public key SHA-256 and the certname is autodetected.

Note that all options must come first, before SHA-256 and file names.
EOF
    exit
fi

# Parse command line arguments
# TODO rewrite using getopt?
auto=0
certname=CERT.RSA
trusted_sha256=
if [ "$1" = --certname ]; then
    certname="$2"
    trusted_sha256="$3"
    shift 3
elif [ "$1" = --auto ]; then
    auto=1
    shift
elif [ "$1" = --manual ]; then
    trusted_sha256="$1"
    shift
else
    echo "Invalid option: $1" >&2
    echo "Should be one of --manual, --certname or --auto" >&2
    exit 2
fi

if [ "$auto" = 0 ]; then
    trusted_sha256=$(echo "$trusted_sha256" | tr '[:upper:]' '[:lower:]')
    cleaned=$(echo "$trusted_sha256" | tr -cd 0123456789abcdef)
    len=$(printf %s "$trusted_sha256" | wc -c)
    if [ "$trusted_sha256" != "$cleaned" ] || [ "$len" != 64 ]; then
        echo "Invalid public key SHA-256: $trusted_sha256"
        exit 2
    fi
fi

# Definitions
any_failure=0
red=$(printf '\033[1;31m')
green=$(printf '\033[32m')
normal=$(printf '\033[0m')

failure() {
    echo "$1: ${red}VERIFICATION FAILURE: $2${normal}" >&2
}
success() {
    echo "$1: ${green}VALID SIGNATURE${normal}"
}
list_unsigned() {
    jarsigner -verify -certs -verbose "$3" | grep -E '^[a-z0-9 ]{10,10}[0-9]' | grep -vE '^sm ' | cut -c '-3,42-' |
        grep -vE "^(s +META-INF/MANIFEST\\.MF| +META-INF/$namebase\\.($sigalg|SF))\$"
}

while [ $# -ge 1 ]; do
    ok=1

    if [ "$auto" = 1 ]; then
        case "$(basename "$1" | tr _- ..)" in
        com.bankid.bus.*)
            # BankID - Swedish eID system
            trusted_sha256=ada2624b35fca3cc340e11899454e550fba982b44d82b97efd16aa3a7a467c16
            certname=BID_ANDR.RSA;;
        se.bankgirot.swish.*)
            trusted_sha256=d31d1d5b73dec8cf45a51114d126dfe60cf264e208826c2ce413c4717c022566
            certname=CERT.RSA;;
        se.slso.app4us.*)
            # Alltid Öppet - Swedish health care and covid19 vaccine booking app
            trusted_sha256=873c14fc8f5a1000d89dee5708c1992014b2c1218eb9c060e68645ca9047d064
            certname=APP4US.RSA;;
        Signal.website.*)
            # trusted cert is 29f34e5f27f211b424bc5bf9d67162c0eafba2da35af35c16416fc446276ba26
            trusted_sha256=29f34e5f27f211b424bc5bf9d67162c0eafba2da35af35c16416fc446276ba26
            certname=SIGNAL_S.RSA;;
        *)
            failure "$1" "unknown APK name. cannot auto-detect key"
            any_failure=1
            shift
            continue
        esac
    fi
    namebase=$(printf %s "$certname" | cut -d '.' -f 1)
    sigalg=$(printf %s "$certname" | cut -d '.' -f 2)

    jarsigner -verify -certs -verbose "$1" >/dev/null || {
        failure "$1" "jarsigner command failed"
        ok=0
    }
    unsigned=$(jarsigner -verify -certs -verbose -sigfile "$namebase" -sigalg "$sigalg" "$1" | grep -E '^[a-z0-9 ]{10,10}[0-9]' | grep -vE '^sm ' | cut -c '-3,42-' |
        grep -cvE "^(s +META-INF/MANIFEST\\.MF| +META-INF/$namebase\\.($sigalg|SF))\$" || true)
    if [ "$unsigned" != 0 ]; then
        failure "$1" "There are $unsigned unsigned files:"
        list_unsigned "$namebase" "$sigalg" "$1" >&2
        ok=0
    fi
    shasum=$(unzip -p "$1" "META-INF/$certname" | openssl pkcs7 -inform der -print_certs | openssl x509 -outform der | sha256sum | cut -d' ' -f 1)
    if [ "$shasum" = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 ]; then  # sha256 of empty string
        failure "$1" "Could not find public key"
        ok=0
    elif [ "$shasum" != "$trusted_sha256" ]; then
        failure "$1" "Untrusted public key hash: $shasum"
        ok=0
    fi

    if [ "$ok" = 1 ]; then
        success "$1"
    else
        any_failure=1
    fi
    shift
done

exit $any_failure
