# CloudFiles

Простая, отказоустойчивая схема с двумя репликами:

>```
>            Client requests:
>         http://sh-a.example.com/
>              |         |
>              |         |
>             /           \
>            /             \
>/--------------\      /--------------\
>|     nginx    |      |     nginx    |
>|   Replica 0  |      |   Replica 1  |
>|    WebDAW    |      |    WebDAW    |
>\--------------/      \--------------/
>   sh-a-r-0         sh-a-r-1.exmaple.com
>            \           /
>             \         /
>          /----------------\
>          |   php+nginx    |
>          |   CloudFiles   |
>          \----------------/
>            bfs.example.com
>                  |
>                  |
>                  |
>          Client Application
>```

В этой схеме - две реплики Reolica 0 и Replica 1, с обоих реплик пользователи могут
скачивать файлы по URL http://sh-a.example.com/.... Фалы на репликах идентичны, новые файлы заливаеются на обе реплики.

Само php-приложение CloudFiles развернуто на третьем сервере CloudFiles. Запросы от клиентов облачного хранилища поступают
по http обычным upload-файла на сервер CloudFiles. Приложение CloudFiles загружает по WebDav файлы на обе реплики и возвращает
публичную ссылку клиенту.

Эта схема отказоустойчива на скачивание - есть две идентичные реплики, каждая из которых может выйти из строя. Но эта схема
не отказоустойчива на upload, т.к. если приложению CloudFiles не удалось залить файл на обе реплики - загрузка считается неуспешной.


Вот более отказоустойчивая схема:

>```
>               Shard A                  .                Shard B
>                                        .
>                                        .
>            Client requests:            .               Client requests:
>         http://sh-a.example.com/       .           http://sh-b.example.com/
>              |         |               .                |         |
>              |         |               .                |         |
>             /           \              .               /           \
>            /             \             .              /             \
>/--------------\      /--------------\  .   /--------------\      /--------------\
>|     nginx    |      |     nginx    |  .  |     nginx    |      |     nginx    |
>|   Replica 0  |      |   Replica 1  |  .  |   Replica 0  |      |   Replica 1  |
>|    WebDAW    |      |    WebDAW    |  .  |    WebDAW    |      |    WebDAW    |
>\--------------/      \--------------/  .  \--------------/      \--------------/
>   sh-a-r-0         sh-a-r-1            .       sh-b-r-0             sh-b-r-1
>            \           /                      /                  /
>             \         /  /-------------------/                  /
>          /----------------\                                    /
>          |   php+nginx    |-----------------------------------/
>          |   CloudFiles   | 
>          \----------------/ 
>            bfs.example.com
>                  |
>                  |
>                  |
>          Client Application
>```

Эта схема имеет два шарда, каждый по две реплики. Эта схема отказоустойчива на скачивание (реплики внутри шарда) и отказойстойчива
на upload. Если приложение CloudFiles не смогло залить файл на одну из реплик Shard A (или на обе) - загрузка на первый шард считается неуспешной,
приложение заливает файл на Shard B. Впринципе количество шардов ничем не ограничено, приложение может идти по списку шардов до тех
пор пока не заливка не будет успешной или список шардов не кончится.

Так же, с помощью шардов можно легко масштабировать дисковое пространство в облаке. Закончилось место на серверах Шарда A и Шарда B - добавляем
еще один новый шард на новом сервер - заливка пойдет на него.

Схема выше имеет одно узкое место - само приложение CloudFiles работает на одном сервере, это легко исправить:

>```
>               Shard A                  .                Shard B
>                                        .
>                                        .
>            Client requests:            .               Client requests:
>         http://sh-a.example.com/       .           http://sh-b.example.com/
>              |         |               .                |         |
>              |         |               .                |         |
>             /           \              .               /           \
>            /             \             .              /             \
>/--------------\      /--------------\  .   /--------------\      /--------------\
>|     nginx    |      |     nginx    |  .  |     nginx    |      |     nginx    |
>|   Replica 0  |      |   Replica 1  |  .  |   Replica 0  |      |   Replica 1  |
>|    WebDAW    |      |    WebDAW    |  .  |    WebDAW    |      |    WebDAW    |
>\--------------/      \--------------/  .  \--------------/      \--------------/
>   sh-a-r-0         sh-a-r-1            .       sh-b-r-0             sh-b-r-1
>        /   \           /    \                   / \                /  \
>                                                                      
>                                                                    
>                                                                 
>                                                                 
>          /----------------\                       /----------------\
>          |   php+nginx    |                       |   php+nginx    |
>          |   CloudFiles   |                       |   CloudFiles   | 
>          \----------------/                       \----------------/ 
>            bfs.example.com                          bfs.example.com
>                  |
>                  |
>                  |
>          Client Application
>```

Само приложение CloudFiles может легко работать на 2х и более серверах - ему ничего не мешает, главное чтобы конфигурации
были идентичными.


