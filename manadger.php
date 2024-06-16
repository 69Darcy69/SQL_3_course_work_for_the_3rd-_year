<?php
session_start(); // Начинаем сессию
// Получаем данные пользователя из сессии
$username = $_SESSION['username'] ?? null;
$password = $_SESSION['password'] ?? null;
// Проверяем, что username и password получены
if (!$username || !$password) {
    header("Location: errorlogin.html");
    exit();
}
// Подключаемся к базе данных
$host = 'localhost';
$dbname = 'GTS';
$conn = pg_connect("host=$host dbname=$dbname user=$username password=$password");
// Проверяем соединение
if (!$conn) {
    header("Location: errorlogin.html");
    exit();
}
// Обработчик для кнопки выхода
if (isset($_POST['logout'])) {
    // Уничтожаем сессию
    session_unset();
    session_destroy();
    pg_close($conn);
    // Перенаправляем на страницу входа
    header("Location: index.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Менеджер</title>
    <!-- Локальные стили -->
    <style>  
        .logout-button:hover {
            background-color: #FF0000;
            color: #FFFFFF;
        }
        .menu-container {
            height: 10vh;
            margin: 10px;
            padding: 10px;
            display: flex;
            flex-direction: row;
            justify-content: center;
            gap: 40px;
        }
        .input-group {
            display: flex;
            align-items: center;
        }
        .btn-success{
            margin-top: auto;
            margin-bottom: auto;
        }
        .low-container {
            height: 87vh;
            padding: 10px;
            overflow: auto;
            display: flex;
            justify-content: center;
        }
        .result-container {
            overflow-x: auto;
            overflow-y: auto;
            padding: 10px;
            color: #000;
            width: 50%;
        }
        .form-control {
            text-align: center;
            font-weight: bold;
        }
        .control {
            background: white;
            width: 70%;
            margin: auto;
        }
        .form-inline {
            display: flex;
            align-items: center;
        }
        p {
            white-space: nowrap; /* предотвращает перенос текста */
            text-align: right;
            flex: 0 0 28%;
        }
        .table-primary {
            margin: auto;
        }

    </style>
</head>
<body>
    <!-- Контейнер меню -->
    <div class="menu-container">
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="input-group mb-3">
                <select class="form-select" name="city_id" style="display: inline-block;">
                    <?php
                    // Получаем значения для списка из базы данных
                    $result = pg_query($conn, 'SELECT "Name", "ID_City" FROM "public"."City"');
                    if ($result) {
                        while ($row = pg_fetch_assoc($result)) {
                            echo "<option value='" . $row['ID_City'] . "'>" . $row['Name'] . "</option>";
                        }
                    }
                    ?>
                </select>
                <button class="btn btn-success" name="add_abonent">Добавить абонента</button>
                <button class="btn btn-success" name="add_worker">Добавить монтера</button>
            </div>
        </form>
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="input-group mb-3">
                <input type="text" name="abonent_search" class="form-control" placeholder="Номер абонента" required>
                <select class="form-select" name="new_pay" style="display: inline-block;">
                    <?php
                    // Получаем значения для списка из базы данных
                    $result = pg_query($conn, "SELECT * FROM get_typepay();");
                    if ($result) {
                        while ($row = pg_fetch_assoc($result)) {
                            echo "<option value='" . $row['ID_Pay'] . "'>" . $row['TypeBenefit'] . "</option>";
                        }
                    }
                    ?>
                </select>
                <button class="btn btn-success" name="new_typepay">Изменить льготу</button>
            </div>
        </form>
        <form method="post">
            <button type="submit" class="btn btn-primary logout-button" name="logout">Выход</button>
        </form>
        <!-- Обработчик кнокпи изменения оплаты -->
        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            // Проверяем, был ли отправлен запрос
            if (isset($_POST['new_typepay'])) {
                $phone_id = $_POST['abonent_search'];
                $pay_id = $_POST['new_pay'];
                $query = "SELECT new_pay($phone_id, $pay_id);";
                $result = pg_query($conn, $query);
            }
        }
        ?>
    </div>
    <div class="low-container">
        <!-- Функция для показа и скрытия контейнеров -->
        <script>
            function showAbonentContainer() {
                var resultContainer = document.getElementById("Abonent");
                resultContainer.style.display = "block";
            }
            function noneAbonentContainer() {
                var resultContainer = document.getElementById("Abonent");
                resultContainer.style.display = "none";
            }
            function showWorkerContainer() {
                var resultContainer = document.getElementById("Worker");
                resultContainer.style.display = "block";
            }
            function noneWorkerContainer() {
                var resultContainer = document.getElementById("Worker");
                resultContainer.style.display = "none";
            }
        </script>
        <!-- Контейнер регистрации нового абонента -->
        <div class="result-container" id="Abonent" style="display: none;">
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <!-- Поля для ввода данных -->
                <input type="text" name="phone_id" class="form-control" placeholder="Введите телефон абонента:" required>
                <input type="text" name="lastname" class="form-control" placeholder="Введите фамилию абонента:" required>
                <input type="text" name="firstname" class="form-control" placeholder="Введите имя абонента:" required>
                <div class="form-inline">
                    <p style="margin-right: 10px;">Отчество</p>
                    <input type="text" name="middlename" value="NULL" class="form-control" placeholder="Введите отчество абонента:" required>
                </div>
                <input type="text" name="street" class="form-control" placeholder="Введите улицу адреса абонента:" required>
                <input type="text" name="home" class="form-control" placeholder="Введите дом адреса абонента:" required>
                <div class="form-inline">
                    <p style="margin-right: 10px;">Строение</p>
                    <input type="text" name="building" value="NULL" class="form-control" placeholder="Введите строение адреса абонента:" required>
                </div>
                <div class="form-inline">
                    <p style="margin-right: 10px;">Квартира</p>
                    <input type="text" name="apartment" value="NULL" class="form-control" placeholder="Введите квартиру адреса абонента:" required>
                </div>
                <input type="text" name="balance" class="form-control" placeholder="Введите сумму первого пополнения:" required>
                <div class="form-inline" style="margin-top: 10px;">
                    <p style="margin-right: 10px;">Тип льготы</p>
                    <div class="input-group mb-3">
                        <!-- Раскрывающийся список -->
                        <select class="form-select" name="pay_id" style="display: inline-block;">
                            <?php
                            // Получаем значения для списка из базы данных
                            $result = pg_query($conn, "SELECT * FROM get_typepay();");
                            if ($result) {
                                while ($row = pg_fetch_assoc($result)) {
                                    echo "<option value='" . $row['ID_Pay'] . "'>" . $row['TypeBenefit'] . "</option>";
                                }
                            }
                            ?>
                        </select>
                    </div>
                </div>
                <div class="form-inline">
                    <p style="margin-right: 10px;">Монтер</p>
                    <div class="input-group mb-3">
                    <!-- Раскрывающийся список -->
                        <select class="form-select" name="worker_id" style="display: inline-block;">
                            <?php
                            // Проверяем, был ли отправлен запрос
                            if (isset($_POST['city_id'])) {
                                $city_id = (int)$_POST['city_id'];
                                $_SESSION['city_id'] = $city_id;
                                // Получаем значения для списка из базы данных
                                $result = pg_query($conn, "SELECT * FROM get_workers_city($city_id);");
                                if ($result) {
                                    while ($row = pg_fetch_assoc($result)) {
                                        echo "<option value='" . $row['ID_Worker'] . "'>" . $row['LastName'] . "</option>";
                                    }
                                } else {
                                    echo "<option value=''>Ошибка загрузки данных</option>";
                                }
                            }
                            ?>
                        </select>
                    </div>
                </div>
                <button class="btn btn-success" name="new_abonent" style="width: 100%;">Добавить</button>
            </form>
            <!-- Обработчик кнопки добавить абонента -->
            <?php
             if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['add_abonent'])) {
                    // Показ контейнера добавления абонента
                    echo "<script>
                                showAbonentContainer();
                            </script>";
                }
            }
            ?>
            <!-- Обработчик кнопки добавть для абонента -->
            <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['new_abonent'])) {
                    // Получение данных из тектовых полей
                    $phone_id = $_POST['phone_id'];
                    $lastname = $_POST['lastname'];
                    $firstname = $_POST['firstname'];
                    $middlename = $_POST['middlename'] ?? null;
                    $street = $_POST['street'];
                    $home = $_POST['home'];
                    $building = $_POST['building'] ?? null;
                    $apartment = $_POST['apartment'] ?? null;
                    $balance = $_POST['balance'];
                    $pay_id = $_POST['pay_id'];
                    $worker_id = $_POST['worker_id'];
                    $city = $_SESSION['city_id'];
                    if($middlename == 'NULL'){
                        $query = "SELECT insert_new_abonent($phone_id, '$lastname', '$firstname', $middlename, $city, '$street', $home, $building, $apartment, $balance, $pay_id, $worker_id);";
                    } else {
                        $query = "SELECT insert_new_abonent($phone_id, '$lastname', '$firstname', '$middlename', $city, '$street', $home, $building, $apartment, $balance, $pay_id, $worker_id);";
                    }
                    // Выполнение запроса на доабвление абонента
                    $result = pg_query($conn, $query);
                    if($result){
                        // Создание логина абонента
                        $newlogin = 'a' . $phone_id;
                        // Создание для абонента роли и добавление в группу пользоватей "Абонент"
                        $adduser = pg_query($conn, "SELECT add_user_abonent('$newlogin');");
                        if($adduser){
                            // Добавление логина абонента в json файл для возможности авторизации
                            $jsonData = file_get_contents("abonent.json");
                            $dataArray = json_decode($jsonData, true);
                            $dataArray[$newlogin] = (int)$phone_id;
                            $newJsonData = json_encode($dataArray, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                            file_put_contents("abonent.json", $newJsonData);
                        }
                        
                    }
                }
            }
            ?>
        </div>
        <!-- Контейнер регистрации нового монтера -->
        <div class="result-container" id="Worker" style="display: none;">
            <!-- Поля для ввода данных -->
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                <input type="text" name="tabel" class="form-control" placeholder="Введите табельный номер:" required>
                <input type="text" name="lastnameworker" class="form-control" placeholder="Введите фамилию монтера:" required>
                <input type="text" name="firstnameworker" class="form-control" placeholder="Введите имя монтера:" required>
                <div class="form-inline">
                    <p style="margin-right: 10px;">Отчество</p>
                    <input type="text" name="middlenameworker" value="NULL" class="form-control" placeholder="Введите отчество монтера:" required>
                </div>
                <button class="btn btn-success" name="new_worker" style="width: 100%;">Добавить</button>
            </form>
            <!-- Обработчик кнопки добавть монтера -->
            <?php
             if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['add_worker'])) {
                    $city_id = (int)$_POST['city_id'];
                    $_SESSION['city_id'] = $city_id;
                    // Показ контейнера добавления монтера и скриытие контейнера абонента
                    echo "<script>
                                noneAbonentContainer();
                                showWorkerContainer();
                            </script>";
                }
            }
            ?>
            <!-- Обработчик кнопки добавть для монтера -->
            <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['new_worker'])) {
                    // Получение данных из тектовых полей
                    $tabel = $_POST['tabel'];
                    $lastname = $_POST['lastnameworker'];
                    $firstname = $_POST['firstnameworker'];
                    $middlename = $_POST['middlenameworker'] ?? null;
                    $city = $_SESSION['city_id'];
                    if($middlename == 'NULL'){
                        $query = "SELECT insert_new_worker($tabel, '$lastname', '$firstname', $middlename, $city);";
                    } else {
                        $query = "SELECT insert_new_worker($tabel, '$lastname', '$firstname', '$middlename', $city);";
                    }
                    // Выполнение запроса на доабвление монтера
                    $result = pg_query($conn, $query);
                    if($result){
                        // Создание логина монтера
                        $newlogin = 'worker' . $tabel;
                        // Создание для монтера роли и добавление в группу пользоватей "Worker"
                        $adduser = pg_query($conn, "SELECT add_user_worker('$newlogin');");
                        if($adduser){
                            // Добавление логина монтера в json файл для возможности авторизации
                            $jsonData = file_get_contents("worker.json");
                            $dataArray = json_decode($jsonData, true);
                            $dataArray[$newlogin] = (int)$tabel;
                            $newJsonData = json_encode($dataArray, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                            file_put_contents("worker.json", $newJsonData);
                        } 
                    }
                }
            }
            ?>
        </div>
    </div>
</body>
</html>