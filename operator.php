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
// Обработчик кнопки выписки из реестра
if (isset($_POST['details_register'])) {
    $number = $_SESSION['number'];
    $year = $_POST['year_register'];
    $query = "SELECT * FROM get_details_register($number , $year)";
    // передаем через сессию запрос, номер телефона абонента и оповещение о том, что это оператор 
    $_SESSION['query_details_register'] = $query;
    $_SESSION['number_details_register'] = $number;
    $_SESSION['flag_int'] = 'operator';
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу
    header("Location: DetailsRegister.php");
    exit();
}
// Обработчик кнопки детализации
if (isset($_POST['details'])) {
    $number = $_SESSION['number'];
    $year = $_POST['year'];
    $month = $_POST['month'];
    $query = "SELECT * FROM get_details($number , $year, $month)";
    // передаем через сессию запрос, номер телефона абонента и оповещение о том, что это оператор 
    $_SESSION['query_details'] = $query;
    $_SESSION['number_details'] = $number;
    $_SESSION['flag_int'] = 'operator';
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу
    header("Location: Details.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Оператор</title>
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
    <!-- Контейнер с меню -->
    <div class="menu-container">
         <!-- Блок раскрывающийся поле для ввода + кнопка -->
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="input-group mb-3">
                <input type="text" name="abonent_search" class="form-control" placeholder="Введите номер абонента:" required>
                <button class="btn btn-success" name="phone">Просмотр абонента</button>
            </div>
        </form>
        <!-- Блок раскрывающийся список + кнопка -->
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="input-group mb-3">
                <select class="form-select" name="city_search" style="display: inline-block;">
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
                <button class="btn btn-success" name="city">Просмотр работ</button>
            </div>
        </form>
        <form method="post">
            <button type="submit" class="btn btn-primary logout-button" name="logout">Выход</button>
        </form>
    </div>
    <!-- Контейнер с отображаемой информацией -->
    <div class="low-container">
        <!-- Скрипт для отображения одного контейнера и скрытия другого -->
        <script>
            function showAbonentContainer() {
                var resultContainer = document.getElementById("AbonentShow");
                resultContainer.style.display = "block";
            }
            function noneAbonentContainer() {
                var resultContainer = document.getElementById("AbonentShow");
                resultContainer.style.display = "none";
            }
            function showWorkContainer() {
                var resultContainer = document.getElementById("WorkShow");
                resultContainer.style.display = "block";
            }
            function noneWorkContainer() {
                var resultContainer = document.getElementById("WorkShow");
                resultContainer.style.display = "none";
            }
        </script>
        <!-- Контейнер с информацией об абоненте -->
        <div class="result-container" id="AbonentShow" style="display: none;">
        <!-- Поля с информацией -->
            <div class="form-inline">
                <p>Номер телефона</p>
                <input id="id_phone" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>ФИО</p>
                <input id="fio" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>Город</p>
                <input id="town" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>Адрес</p>
                <input id="adress" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>Тип льготы</p>
                <input id="pay" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>Статус телефона</p>
                <input id="status" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>Дата списания</p>
                <input id="lastwrite-off" type="text" class="control form-control" readonly>
            </div>
            <div class="form-inline">
                <p>Баланс</p>
                <input id="balance" type="text" class="control form-control" readonly>
            </div>
            <!-- Обработчик кнопки Просмотр абонента -->
            <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['phone'])) {
                    $number = $_POST['abonent_search'];
                    $_SESSION['number'] = $number;
                    $query = "SELECT * FROM get_abonent_info($number)";
                    $result = pg_query($conn, $query);
                    if (!$result) {
                        echo "Ошибка выполнения запроса.";
                    } else {
                        $row = pg_fetch_assoc($result);
                        // Отображение контейнера абонента и отправка информации в поля
                        echo "<script>
                                showAbonentContainer();
                                document.getElementById('id_phone').value = '" . $row['ID_Phone'] . "';
                                document.getElementById('fio').value = '" . $row['FIO'] . "';
                                document.getElementById('town').value = '" . $row['Town'] . "';
                                document.getElementById('adress').value = '" . $row['Addres'] . "';
                                document.getElementById('pay').value = '" . $row['TypeBenefit'] . "';
                                document.getElementById('status').value = '" . $row['NameStatus'] . "';
                                document.getElementById('lastwrite-off').value = '" . $row['LastWrite-off'] . "';
                                document.getElementById('balance').value = '" . $row['Balance'] . "';
                            </script>";
                    }
                }
            }
            ?>
            <!-- Раскрывающиеся списки с кнопками -->
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                <div class="input-group mb-3" style="margin-top: 10px;">
                    <select class="form-select" name="year">
                        <?php
                        // Получаем значения для списка из базы данных
                        $result = pg_query($conn, "SELECT * FROM get_year_intercity($number);");
                        if ($result) {
                            while ($row = pg_fetch_assoc($result)) {
                                echo "<option value='" . $row['year'] . "'>" . $row['year'] . "</option>";
                            }
                        }
                        ?>
                    </select>
                    <select class="form-select" name="month">
                        <?php
                        // Получаем значения для списка из базы данных
                        $result = pg_query($conn, "SELECT * FROM get_month_intercity($number);");
                        if ($result) {
                            while ($row = pg_fetch_assoc($result)) {
                                echo "<option value='" . $row['month'] . "'>" . $row['month'] . "</option>";
                            }
                        }
                        ?>
                    </select>
                    <button class="btn btn-success" name="details">Просмотр детализации</button>
                </div>
            </form>
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                <div class="input-group mb-3" style="margin-top: 10px;">
                    <select class="form-select" name="year_register">
                        <?php
                        // Получаем значения для списка из базы данных
                        $result = pg_query($conn, "SELECT * FROM get_year_register($number);");
                        if ($result) {
                            while ($row = pg_fetch_assoc($result)) {
                                echo "<option value='" . $row['year'] . "'>" . $row['year'] . "</option>";
                            }
                        }
                        ?>
                    </select>
                    <button class="btn btn-success" name="details_register">Просмотр пополнений</button>
                </div>
            </form>
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                <div class="form-inline">
                    <p style="margin-right: 10px;">Монтер</p>
                    <div class="input-group mb-3">
                        <select class="form-select" name="worker_id" style="display: inline-block;">
                            <?php
                            // Получаем значения для списка из базы данных
                            $result = pg_query($conn, "SELECT * FROM get_workers_phone($number);");
                            if ($result) {
                                while ($row = pg_fetch_assoc($result)) {
                                    echo "<option value='" . $row['id_worker'] . "'>" . $row['lastname'] . "</option>";
                                }
                            }
                            ?>
                        </select>
                        <button class="btn btn-success" name="create_work">Создать заявку</button>
                    </div>
                </div>
            </form>
            <!-- Обработчик кнокпи создания заявки на ремонт -->
            <?php
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['create_work'])) {
                    $number = $_SESSION['number'];
                    $worker_id = $_POST['worker_id'];
                    // Отправка запроса
                    $query = "SELECT insert_repair_job($worker_id, $number);";
                    $result = pg_query($conn, $query);
                }
            }
            ?>
        </div>
        <!-- Контейнер с информацией о монтаже -->
        <div class="result-container" id="WorkShow" style="width: 80%;" style="display: none;">  
              <!-- Меню контейнера -->
            <div class="menu-container">
                <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                    <div class="input-group mb-3">
                        <button class="btn btn-success" value="get_workers_by_city" name="show">Просмотр монтеров</button>
                        <button class="btn btn-success" value="get_install_by_city" name="show">Просмотр работ по установке</button>
                        <button class="btn btn-success" value="get_repair_by_city" name="show">Просмотр работ по ремонту</button>
                    </div>
                </form>
                <!-- Обработчики скрытия контейнера -->
                <?php
                // Скрытие монтажного контейнера при запуске страницы
                if ($_SERVER["REQUEST_METHOD"] != "POST") {
                    echo "<script>noneWorkContainer(); </script>";
                }
                // Обработка кнопки просмотр работ
                if ($_SERVER["REQUEST_METHOD"] == "POST") {
                    // Проверяем, был ли отправлен запрос
                    if (isset($_POST['city'])) {
                        $city_id = $_POST['city_search'] ?? 1;
                        $_SESSION['city_id'] = $city_id;
                        // скрытие контейнера абонента, показ монтажного контейнера
                        echo "<script>noneAbonentContainer(); showWorkContainer(); </script>";
                    }
                    // скрытие монтажного контейнера при нажатии на показать работы
                    if (isset($_POST['phone'])){
                        echo "<script>noneWorkContainer(); </script>";
                    }
                }
                ?>
            </div>
            <?php
            // обработчик кнопок монтажного контейнера
            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                // Проверяем, был ли отправлен запрос
                if (isset($_POST['show'])) {
                    $city_id = $_SESSION['city_id'] ?? 1;
                    // Получаем название функции из кнопки, которая была нажата
                    $func = $_POST['show'];
                    $query = "SELECT * FROM $func($city_id)";
                    // Обработка запроса
                    $result = pg_query($conn, $query);
                    if (!$result) {
                        echo "Ошибка выполнения запроса";
                    } else {
                        // Вывод результатов запроса в таблицу
                        echo "<table class='table-primary'>";
                        $row = pg_fetch_assoc($result);
                        echo "<tr>";
                        foreach ($row as $column_name => $value) {
                            echo "<th>" . $column_name . "</th>";
                        }
                        echo "</tr>";
                        // Вывод данных таблицы
                        pg_result_seek($result, 0);
                        while ($row = pg_fetch_assoc($result)) {
                            echo "<tr>";
                            foreach ($row as $value) {
                                echo "<td>" . $value . "</td>";
                            }
                            echo "</tr>";
                        }
                        echo "</table>";
                    }
                }
            }
            ?>   
        </div>
    </div>

</body>
</html>