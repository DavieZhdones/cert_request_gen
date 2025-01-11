Project: cert_request_gen.sh<br/>
Author: @AntonenkovArt<br/>
Language: bash<br/>

This project is a wrapper to simplify the procedure of generating requests for "gosuslugi.ru" portal to issue TLS certificates.<br/>
The project is based on OpenSSL with the pre-installed gost-engine package.<br/>
OpenSSL is used to generate keys and request files. The gost-engine package is required to use Russian cryptographic algorithms.<br/>

Request templates are compiled in accordance with the instructions provided on "gosuslugi.ru" portal.

Using a text editor, you can change the request template in accordance with the instructions provided on "gosuslugi.ru" portal.

Distribution composition:<br/>
cert_request_gen.sh - executable file, used to generate<br/>
output - directory, containing key pairs and requests to issue certificates<br/>
filepaths.conf - config with project filepaths<br/>
rsa_dv.template - RSA DV certificate template<br/>
rsa_ov_ip.template - RSA OV certificate template for IP<br/>
rsa_ov_fl.template - RSA OV certificate template for FL<br/>
rsa_ov_yl.template - RSA OV certificate template for YL<br/>
gost_dv.template - GOST DV certificate template<br/>
gost_ov_ip.template - GOST OV certificate template for IP<br/>
gost_ov_fl.template - GOST OV certificate template for FL<br/>
gost_ov_yl.template - GOST OV certificate template for YL<br/>
README - description of the distribution<br/>

Dependencies:<br/>
getopt from util-linux (tested on 2.40.2)<br/>
OpenSSL (tested on 3.4.0)<br/>
gost-engine (https://github.com/gost-engine/engine)<br/>

General help:<br/>
Usage: ./cert_request_gen.sh command [ command_opts ] [ opts_args ]<br/>
Note: Check filepaths.conf to see utility paths.<br/>

Standard commands:<br/>
rsa         Generate certificate request using RSA encryption<br/>
gost        Generate certificate request using GOST encryption<br/>
help        Display help<br/>
version     Display version<br/>

RSA command help:<br/>
Usage: rsa [ command_opts ] [ opts_args ]<br/>

RSA options:<br/>
-help                 Display help<br/>
-type dv|ov           Validation type. Required.<br/>
-declarant ip|fl|yl   Declarant type. Required for ov type, optional for dv.<br/>
-keylength 2048|4096  Keypair bit length. Optional. 256 set by default.<br/>
-count 1-100          Number of generated requests. Optional.<br/>

GOST command help:<br/>
Usage: gost [ command_opts ] [ opts_args ]<br/>

GOST options:<br/>
-help                Display help<br/>
-type dv|ov          Validation type. Required.<br/>
-declarant ip|fl|yl  Declarant type. Required for ov type, optional for dv.<br/>
-keylength 256|512	 Keypair bit length. Optional. 256 set by default.<br/>
-paramset XA|A|B     Keypair paramset. Optional. XA is default and the only variant for 256 keypair, A|B - for 512 keypair (A by default).<br/>
-count 1-100          Number of generated requests. Optional.<br/>


