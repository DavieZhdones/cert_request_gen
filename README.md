Project: cert_request_gen.sh
Author: @AntonenkovArt
Language: bash

This project is a wrapper to simplify the procedure of generating requests for "gosuslugi.ru" portal to issue TLS certificates.
The project is based on OpenSSL with the pre-installed gost-engine package.
OpenSSL is used to generate keys and request files. The gost-engine package is required to use Russian cryptographic algorithms.

Request templates are compiled in accordance with the instructions provided on "gosuslugi.ru" portal.

Using a text editor, you can change the request template in accordance with the instructions provided on "gosuslugi.ru" portal.

Distribution composition:
cert_request_gen.sh - executable file, used to generate
output - directory, containing key pairs and requests to issue certificates
rsa_dv.template - RSA DV certificate template
rsa_ov_ip.template - RSA OV certificate template for IP
rsa_ov_fl.template - RSA OV certificate template for FL
rsa_ov_yl.template - RSA OV certificate template for YL
gost_dv.template - GOST DV certificate template
gost_ov_ip.template - GOST OV certificate template for IP
gost_ov_fl.template - GOST OV certificate template for FL
gost_ov_yl.template - GOST OV certificate template for YL
README - description of the distribution

Dependencies:
getopt from util-linux (tested on 2.40.2)
OpenSSL (tested on 3.4.0)
gost-engine (https://github.com/gost-engine/engine)

General help:
Usage: ./cert_request_gen.sh command [ command_opts ] [ opts_args ]
Note: Check filepaths.conf to see utility paths.

Standard commands:
rsa         Generate certificate request using RSA encryption
gost        Generate certificate request using GOST encryption
help        Display help
version     Display version

RSA command help:
Usage: rsa [ command_opts ] [ opts_args ]

RSA options:
-help                 Display help
-type dv|ov           Validation type. Required.
-declarant ip|fl|yl   Declarant type. Required for ov type, optional for dv.
-keylength 2048|4096  Keypair bit length. Optional. 256 set by default.
-count 1-100          Number of generated requests. Optional.

GOST command help:
Usage: gost [ command_opts ] [ opts_args ]

GOST options:
-help                Display help
-type dv|ov          Validation type. Required.
-declarant ip|fl|yl  Declarant type. Required for ov type, optional for dv.
-keylength 256|512	 Keypair bit length. Optional. 256 set by default.
-paramset XA|A|B     Keypair paramset. Optional. XA is default and the only variant for 256 keypair, A|B - for 512 keypair (A by default).
-count 1-100          Number of generated requests. Optional.


