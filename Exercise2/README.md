# Exercise 2


Choose one of the applications in the folder. Containerize it with Docker and automate the build and push processes. 
To complete this task, the following recommendations are provided:

# 1. Choose an application:

I have chosen to proceed with the Python application (calculator.py). I have downloaded them, and included them in my GitHub repo, in this folder.
The requirements are listed inside of requirements.txt.

QUICK NOTE: I have looked at the code of the application, and noticed it uses `flask` but it is not in `requirements.txt`, and because of that, it crashed the app when I tried to build it, so I have added it to `requirements.txt`

![Build Fail](Screenshots/BuildNoFlask.png)

# 2. Create a Dockerfile:

I have created the Dockerfile and placed it in the same folder as the requirements and the app:

```
FROM python:3.13.0a4-slim-bullseye

WORKDIR /Exercise2

COPY . /Exercise2

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "calculator:app"]
```

Some notes:
1. I have chosen that particular python version, as I have seen on Dockerhub that the newest version appeared to have failed some checks, so in order to not risk the app not working, I went with the previous version
2. I used `EXPOSE 8080` for the port to be usuable
3. Since `gunicorn` was one of the requirements in the text file, I have used that, to run the application, with the `-b` argument to bind the port.


# 3. Local Testing:

Building the image locally:

```
PS C:\Users\Shadow\Desktop\ProiectInternship\ProiectInternship\Exercise2> docker build -t calculator-app .
[+] Building 5.0s (10/10) FINISHED                                                                 docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 247B                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.13.0a4-slim-bullseye                                   1.0s
 => [auth] library/python:pull token for registry-1.docker.io                                                      0.0s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [1/4] FROM docker.io/library/python:3.13.0a4-slim-bullseye@sha256:f69a0965c4c667a897c67105a8f1dccfbdad69d9e60  0.0s
 => [internal] load build context                                                                                  0.0s
 => => transferring context: 51.65kB                                                                               0.0s
 => CACHED [2/4] WORKDIR /Exercise2                                                                                0.0s
 => [3/4] COPY . /Exercise2                                                                                        0.0s
 => [4/4] RUN pip install --no-cache-dir -r requirements.txt                                                       3.7s
 => exporting to image                                                                                             0.2s
 => => exporting layers                                                                                            0.1s
 => => writing image sha256:2cecdd49bb0dc39ab26833bd02d5d6e4b19e3dd7fce93b0167a1498294b9c5f2                       0.0s
 => => naming to docker.io/library/calculator-app                                                                  0.0s
```

Running the image:

```
PS C:\Users\Shadow\Desktop\ProiectInternship\ProiectInternship\Exercise2> docker run -p 8080:8080 calculator-app
[2025-03-14 21:35:04 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2025-03-14 21:35:04 +0000] [1] [INFO] Listening at: http://0.0.0.0:8080 (1)
[2025-03-14 21:35:04 +0000] [1] [INFO] Using worker: sync
[2025-03-14 21:35:04 +0000] [7] [INFO] Booting worker with pid: 7
```

Testing the image:

I have entered "localhost:8080" in my browser, to access the app.

The app works by inputting numbers separated by commas, then selecting either multiply/add, and clicking the "Calculate" button:

![Addition Test](Screenshots/LocalAdd.png)

![Multiplication Test](Screenshots/LocalMulti.png)

To close the app, I used the command `docker ps` to see all active containers, then I used `docker stop` followed by the ID of the container, to stop it.
To view more details, we can use the `docker logs` command, followed by the ID of the container, to see all the logs related to it.

```
PS C:\Users\Shadow> docker logs 53752819611d
[2025-03-14 22:08:26 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2025-03-14 22:08:26 +0000] [1] [INFO] Listening at: http://0.0.0.0:8080 (1)
[2025-03-14 22:08:26 +0000] [1] [INFO] Using worker: sync
[2025-03-14 22:08:26 +0000] [7] [INFO] Booting worker with pid: 7
```

# 4. Set Up a Docker Registry:

Created an account on Docker Hub, then created the repository:

![Docker Repository](Screenshots/DockerHub.png)

To push the image to the repo, I tagged the image as "test", I logged in to docker, then I pushed it to the repo:

```
PS C:\Users\Shadow> docker tag calculator-app razvanspunei/proiectinternship:test
PS C:\Users\Shadow> docker login
Authenticating with existing credentials...
Login Succeeded
PS C:\Users\Shadow> docker push razvanspunei/proiectinternship:test
The push refers to repository [docker.io/razvanspunei/proiectinternship]
c4d658f33c53: Pushed
eee5a417381f: Pushed
ea9234c93ec2: Pushed
ff331540e912: Mounted from library/python
e655292d3eb9: Mounted from library/python
07e75ca20fee: Mounted from library/python
3ddd373c9e01: Mounted from library/python
3c8879ab2cf2: Mounted from library/python
test: digest: sha256:2e35ab3dde2f7adcdcd3a7a44347fccb07279f989224350ac8ef1604c841ac0e size: 1996
```

How it appears after the push:

![Docker Repository](Screenshots/DockerPushed.png)


# 5. Automation:

##	Automate the following steps using GitHub Actions:

##	Trigger the build whenever changes are pushed to the repository on branch main/master

##	Build the Docker image using the Dockerfile

##	Tag the Docker image with a commit hash

##	Push the Docker image to the Docker registry

# Bonus / Nice to have:

## B1. Ensure the application catches the Docker container's stop signal and performs a clean shutdown

## B2. Configure environment variables for sensitive information
