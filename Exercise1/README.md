# Exercise 1

The following tasks should be performed from within a Docker container. 
Download and install Docker Desktop, then from terminal run an Ubuntu container: 

`docker run -it ubuntu`

## 1. Lookup the Public IP of cloudflare.com

To perform this task, I first had to install the dnsutils package, so i can use the `nslookup` command:

`apt update && apt install -y dnsutils`

I have then used the command to lookup the public IP of cloudflare.com, and I have received the following in the console:

```
#nslookup cloudflare.com
Server:         192.168.65.7
Address:        192.168.65.7#53

Non-authoritative answer:
Name:   cloudflare.com
Address: 104.16.133.229
Name:   cloudflare.com
Address: 104.16.132.229
Name:   cloudflare.com
Address: 2606:4700::6810:84e5
Name:   cloudflare.com
Address: 2606:4700::6810:85e5
```


## 2. Map IP address 8.8.8.8 to hostname google-dns 

To map the IP address 8.8.8.8 to google-dns, I have to add it into the etc/hosts file.
I can either use `nano`, and add it manually (in which case I have to install `nano` since docker does not have it by default), or use a command for that.
I have used the following command:

`echo "8.8.8.8 google-dns" >> /etc/hosts`

From what I observed, Ubuntu normally requires me to use `sudo` to edit files inside of `etc/`, however with Docker, that does not seem to be required (and the `sudo` package seems to not be installed)
Despite not using `nano` to manually map the IP to the hostname and using a command, I have still installed it, and opened the file, to check if everything is in order.

```                                                           
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.2      346480b28468
8.8.8.8 google-dns
```

# 3. Check if the DNS Port is Open for google-dns

I installed the `telnet` package, so I can use the following command:

`telnet 8.8.8.8 53`

This returned in the console the following, which showed that the port is indeed open:

```
# telnet 8.8.8.8 53
Trying 8.8.8.8...
Connected to 8.8.8.8.
Escape character is '^]'.
Connection closed by foreign host.
```
 
## 4. Modify the System to Use Google’s Public DNS 
### - Change the nameserver to 8.8.8.8 instead of the default local configuration. 

To change the nameserver, we can do so in the `resolv.conf` file. By default it has:

`nameserver 192.168.65.7`

Which I have changed to (using `nano`):

`nameserver 8.8.8.8`

###	- Perform another public IP lookup for cloudflare.com and compare the results. 

Upon performing the lookup, we can notice that the IP is now changed:

Before:
```
#nslookup cloudflare.com
Server:         192.168.65.7
Address:        192.168.65.7#53

Non-authoritative answer:
Name:   cloudflare.com
Address: 104.16.133.229
Name:   cloudflare.com
Address: 104.16.132.229
Name:   cloudflare.com
Address: 2606:4700::6810:84e5
Name:   cloudflare.com
Address: 2606:4700::6810:85e5
```

After:
```
#nslookup cloudflare.com
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   cloudflare.com
Address: 104.16.132.229
Name:   cloudflare.com
Address: 104.16.133.229
Name:   cloudflare.com
Address: 2606:4700::6810:84e5
Name:   cloudflare.com
Address: 2606:4700::6810:85e5
```

## 5. Install and verify that Nginx service is running 

I have used `apt install -y nginx` to install the package.
After that, I had to use `service nginx start`, to start it, and to check if Nginx is actually running, I have used `service nginx status`

The result is as follows:
```
# service nginx start
 * Starting nginx nginx                                                                                                     [ OK ] 
# service nginx status
 * nginx is running
```

## 6.Find the Listening Port for Nginx

I have run the command:

`ss -tulnp | grep nginx`

This command displays info about the network socket. The options I used, in order, show me the TCP sockets, UDP sockets, listening sockets, the addresses and the process. I used `grep` so I could display only the results for `nginx`
This is what information was displayied after running the command:
```
# ss -tulnp | grep nginx
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=797,fd=5))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=797,fd=6))
```

From this we can tell that Nginx is listening on port 80.

#Bonus / Nice to Have: 
## B1. Change the Nginx Listening port to 8080

In order to do this, I navigated to the folder `etc/nginx/sites-available`, and inside, there is the file `default`.
There, I found this line, for the port of the default server.
```
listen 80 default_server;
listen [::]:80 default_server; 
```

I changed it from 80 to 8080:
```
listen 8080 default_server;
listen [::]:8080 default_server;
```

After this I have restarted `nginx` for it to start on the new port:

`service nginx restart`

And then I have used the command from above, to see if it actually uses the new port or not:

`# ss -tulnp | grep nginx`

From this output, we can observe that the new port (8080) is being used instead of the one it had previously:

```
# ss -tulnp | grep nginx
tcp   LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=43,fd=5))
tcp   LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=43,fd=6))
```

## B2. Modify the default HTML page title from: "Welcome to nginx!" → "I have completed the Linux part of the DevOps internship project"

To edit the HTML page title, I have to find the HTML file that nginx uses.
It is located inside `var/www/html/`, and its named `index-nginx-debian.html`
From there we just have to find the line for the title, and replace whatever is there with our text.
This is the old one:

`<title>Welcome to nginx!</title>`

This is the new one:

`<title>I have completed the Linux part of the DevOps internship project</title>`

Normally I would need a graphical interface, so I can check the changes in a browser.
I do not have a graphical interface for this docker container, so I have tried a workaround.
I have installed curl:

`apt install -y curl`

I then ran this command:

`curl http://localhost:8080 | grep "<title>"`

With this command, I am trying to fetch the HTML page from localhost:8080 (where our nginx html page is), then with grep, I am specifically trying to output the field with the title.
It has returned this output, which means that the title has indeed been changed:

```
# curl http://localhost:8080 | grep "<title>"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   662  100   662    0     0   635k      0 --:--:-- --:--:-- --:--:--  646k
<title>I have completed the Linux part of the DevOps internship project</title>
```

