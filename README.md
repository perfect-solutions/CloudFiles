# CloudFiles


/--------------\      /--------------\
|     nginx    |      |     nginx    |
|   Replica A  |      |   Replica B  |
|    WebDAW    |      |    WebDAW    |
\--------------/      \--------------/
            \           /
             \         /
          /----------------\
          |   php+nginx    |
          |  BFS Uploader  |
          \----------------/
                  |
                  |
                  |
          Client Application

