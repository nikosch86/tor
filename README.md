# tor
multi purpose tor docker image  
by default this image runs a middle relay, this helps speed up the tor network.  
running this image does not make you an exit node, so no harassment or abuse is to be expected  
run the container like this:  
`docker run -it -p 9001:9001 -p 9050:9050 nikosch86/tor`  
the socks port will be exposed under port `9050` for your clients to use.  

