Installing Chef server
======================

It has been such a duhanting task to do this based on OpsCodes documentation 
 so I decieded to write this script / set of scripts.


In case you need to reset the chef-webui admin server [I know I did ...]
------------------------------------------------------------------------
> []# \curl http://localhost:5984/chef/_design/users/_view/all

This cmd will returns all the users
On my server:
{"total_rows":1,"offset":0,"rows":[
{"id":"273fda8c-eea6-408a-bfa1-165df3ed59b1","key":"admin","value":{"_id":"273fda8c-eea6-408a-bfa1-165df3ed59b1","_rev":"1-ca28827af4dd8e0ad2578b50476523d2","salt":"Sat Dec 29 00:06:47 +0200 2012cpCdvU4rxtehkgOj7REDdYrboxNzWS","name":"admin","json_class":"Chef::WebUIUser","admin":true,"openid":null,"password":"5323ef01432b130b55806ed6b870ea60b367f252","chef_type":"webui_user"}}
]}

To delete the admin user (which will be created by the service upon restart):
> []# curl -X DELETE http://localhost:5984/chef/273fda8c-eea6-408a-bfa1-165df3ed59b1?rev=1-ca28827af4dd8e0ad2578b50476523d2

The set the new password is in /etc/chef/webui.rb 
I set it to the chef default :: p@ssw0rd1
> web_ui_admin_default_password "p@ssw0rd1"

Now restart your chef-server and chef-server-webui
> []# /etc/init.d/chef-server restart
> []# /etc/init.d/chef-server-webui restart

You should be able to login ... wiht p@ssw0rd1


Known Issues
------------
On the CentOS 6 [6.2 to be precise] installation chef-solr will not start - still looking into this [Or if you solve this issue please share] 
