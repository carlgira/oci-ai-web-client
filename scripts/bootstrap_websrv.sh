#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install and configure Apache Web server with PHP support"
yum -y install httpd php git

case `hostname` in
"websrv1")  color="linen";;
"websrv2")  color="lightgrey";;
esac

cat >/var/www/html/index.php << EOF
<!DOCTYPE html>
<html>
<head>
<title>OCI vision web client</title>
<style>
body {
  background-color: ${color};
}
#text1 {
  font-size:25px;
  color:black;
}
#text2 {
  font-size:40px;
  color:red;
}
#text3 {
  font-size:25px;
}
td {
  background-color:#D0D0FF;
  text-align: center;
  border: 2px solid blue;
  padding:30px
}
table {
  margin-left:auto;
  margin-right:auto;
  border-spacing: 50px;
}

</style>
</head>
<body>
<table>
<tr>
<td>
<div id="text1"> This web page is served by server </div>
<p>
<div id="text2"> <?php echo gethostname(); ?> </div>
</td>
</tr>
</table>

<div id="text3">
OCI vision web client
<br>
<a href="https://github.com/carlgira/oci-tf-vision-web-client">https://github.com/carlgira/oci-tf-vision-web-client</a>
</div>
</body>
</html>
EOF

systemctl start httpd
systemctl enable httpd

echo "========== Clone app"
git clone https://github.com/carlgira/oci-vision-web-client /var/www/html/oci-vision-web-client


echo "========== Replace variables"
sed -i "s/##endpoint##/mbvypf2ufli7fhpusbqrd6h3zy.apigateway.eu-frankfurt-1.oci.customer-oci.com/g" /var/www/html/oci-vision-web-client/js/variables.json
sed -i "s/##path##/analize-image/g" /var/www/html/oci-vision-web-client/js/variables.json
sed -i "s/##modelId##/ocid1.datalabelingdataset.oc1.eu-frankfurt-1.amaaaaaaqtij3maavxwtdmb3phrpzbio5grfu77bpaez5ufendrjwda3gitq/g" /var/www/html/oci-vision-web-client/js/variables.json
sed -i "s/##labels##/Eiffel_Tower:Eiffel Tower,Stonehenge:Stonehenge,Trevi_fountain:Trevi fountain,Great_Pyramid_of_Giza:Pyramid of Giza,Louvre_Pyramid:Louvre Pyramid/g" /var/www/html/oci-vision-web-client/js/variables.json


echo "========== Open port 80/tcp in Linux Firewall"
/bin/firewall-offline-cmd --add-port=80/tcp


echo "========== Final reboot"
reboot