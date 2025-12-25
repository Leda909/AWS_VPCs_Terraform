# Create PRIVATE IP connection IAM MongoDB EC2

Lanch EC2 (Follow inst ac image)

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PrivIP_IAM_Mongodb_EC2_1.png" width="60%" alt="Create EC2 for MongoDB IAM with Private IP VPC">

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PrivIP_IAM_Mongodb_EC2_2.png" width="60%" alt="Create EC2 for MongoDB IAM with Private IP VPC">

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PrivIP_IAM_Mongodb_EC2_3.png" width="60%" alt="Create EC2 for MongoDB IAM with Private IP VPC">

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PrivIP_IAM_Mongodb_EC2_4_redo_ENABLE.png" width="60%" alt="Create EC2 for MongoDB IAM with Private IP VPC">

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PrivIP_IAM_Mongodb_EC2_5_redo.png" width="60%" alt="Create EC2 for MongoDB IAM with Private IP VPC">

# Create PUBLIC IP connection IAM Node App EC2

Lanch EC2 (Follow inst ac image)

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PubIP_IAM_NodeApp_EC2_1.png" width="60%" alt="Create EC2 for Node.js App IAM with PUBLIC IP VPC">

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PubIP_IAM_NodeApp_EC2_2.png" width="60%" alt="Create EC2 for Node.js App IAM with PUBLIC IP VPC">

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PubIP_IAM_NodeApp_EC2_3.png" width="60%" alt="Create EC2 for Node.js App IAM with PUBLIC IP VPC">

Place the `IAM_app_user_data.sh` script in the User Data ac image shows

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PubIP_IAM_NodeApp_EC2_5_user_data.png" width="60%" alt="Create EC2 for Node.js App IAM with PUBLIC IP VPC">

# Check your deployed Application with MongoDB with your VPC

<img src="../2_create_PrivIP_IAM_MongoDB_EC2_and_PubIP_IAM_App_EC2_with_VPC/images/PubIP_IAM_NodeApp_connect.png" width="60%" alt="Create EC2 for Node.js App IAM with PUBLIC IP VPC">

`http://<Public IP of Node App EC2>/posts`

### In case of Reboot of your Instances:

* The Public IP of MongoDB NOT going to change - So, it would run again withouth problem

* However, EC2 instance Only picks up User Data at the first time, when you lanch your Instance.
  
  Hence, you going to need to log into your EC2 in your `bash` terminal and redo some of the commands to start the node App.

  Bear in mind to use UBUNTU `ssh -i "se-adel-basic-key-pair.pem" ubuntu@108.129.123.72` <br>
  instead ROOT user `root@108.129.123.72`

  go into your app folder<br>
  `cd nodejs20-se-test-app-2025/app`

  DB connection env var<br>
  `export DB_HOST=mongodb://<PRIVATE IP MONGODB>:27017/posts`
    
  npm install <br>
  `sudo npm install`

  seed database<br>
  `node seeds/seed.js`

  start app<br>
  `pm2 start app.js`