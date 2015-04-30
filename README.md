# CloudFiles

Простая, отказоустойчивая схема с двумя репликами:

>
>            Client requests:
>         http://sh-a.example.com/
>              |         |
>	      |         |
>             /           \
>            /             \
>/--------------\      /--------------\
>|     nginx    |      |     nginx    |
>|   Replica A  |      |   Replica B  |
>|    WebDAW    |      |    WebDAW    |
>\--------------/      \--------------/
>   sh-a-r-0         sh-a-r-1.exmaple.com
>            \           /
>             \         /
>          /----------------\
>          |   php+nginx    |
>          |  BFS Uploader  |
>          \----------------/
>	    bfs.example.com
>                  |
>                  |
>                  |
>          Client Application
>

