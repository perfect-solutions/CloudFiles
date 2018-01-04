# Perfect Solutions CloudFiles

Fast + Scalable + High Availabile + Simple + Small - Cloud Files Storage

* Only 2 requirements: PHP 5.4+ and Nginx
* Only NN rows of code
* Only NN rows of Nginx configuration
* Only NN rows of Application configuration
* NN Deployment Methods: puppet, ansible, docker, bash
* Download Performance = Nginx Performance * Shards Count
* Upload Performance = IO Performance * Shards Count
* http/http2/spdy/https compatible for download and upload

### Interesting facts

* [0 single points of failure](ARCHITECTURE.md)
* Upload and Download High Availability
* Stable Solution: 0 bugs found after testing in 8 external really-business projects
* We use it for own projects too

### How hard to integration?

* NN client libraries: PHP
* Simple usage: examples after this text
* Auto-test infrastructure after deployment
* Auto-deployment: read [DEPLOYMENT.md](DEPLOYMENT.md)

## Examples

PHP Example

>```php
> //create file for test
> $r = rand(111111,9999999);
> file_put_contents(__DIR__."/testfile", $r);
> 
> //construct class
> $cf = new CloudFilesClient('http://upload.example.com/');
> 
> //upload file
> $url = $cf->upload(__DIR__."/testfile", "/testdir/testfile");
>
> //download file
> if (file_get_contents($url) == $r) echo "!";
>
> //remove file
> if ($cf->remove($url)) echo "!";
> 
> //check file exists after deletion
> if (@file_get_contents($url) === null)  echo "!";
>```

