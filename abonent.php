<?php
session_start(); // Начинаем сессию
// Получаем данные пользователя из сессии
$username = $_SESSION['username'] ?? null;
$password = $_SESSION['password'] ?? null;
$json_data = file_get_contents("abonent.json");
$data_array = json_decode($json_data, true);
$number = $data_array[$username] ?? null;
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
    $year = $_POST['year_register'];
    $query = "SELECT * FROM get_details_register($number , $year)";
    // передаем через сессию запрос, номер телефона абонента и оповещение о том, что это абонент 
    $_SESSION['query_details_register'] = $query;
    $_SESSION['number_details_register'] = $number;
    $_SESSION['flag_int'] = 'abonent';
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу
    header("Location: DetailsRegister.php");
    exit();
}
// Обработчик кнопки детализации
if (isset($_POST['details'])) {
    $year = $_POST['year'];
    $month = $_POST['month'];
    $query = "SELECT * FROM get_details($number , $year, $month)";
    // передаем через сессию запрос, номер телефона абонента и оповещение о том, что это абонент
    $_SESSION['query_details'] = $query;
    $_SESSION['number_details'] = $number;
    $_SESSION['flag_int'] = 'abonent';
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
    <title>Абонент</title>
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
        <!-- Внешний апи - оформлен в виде кнопки -->
        <a href="https://codificator.ru/code/phone/" target="_blank" class="btn btn-link">Посмотреть телефонные коды</a>
        <!-- Форма с методом пост и отправкой сообщений в обработчики -->
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="input-group mb-3">
                <input type="text" name="sum_pay" class="form-control" placeholder="Введите сумму" required>
                <button class="btn btn-success" name="pay">Пополнить баланс</button>
            </div>
        </form>
        <form method="post">
            <button type="submit" class="btn btn-primary logout-button" name="logout">Выход</button>
        </form>
        <!-- Обработка пополнения баланса -->
        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            // Проверяем, был ли отправлен запрос
            if (isset($_POST['pay'])) {
                $sum_pay = $_POST['sum_pay'];
                $_SESSION['sum_pay'] = $sum_pay;
                $_SESSION['number_pay'] = $number;
                session_write_close();
                pg_close($conn);
                header("Location: pay.php");
                exit();
            }
        }
        ?>
    </div>
    <div class="low-container">
        <!-- Контейнер с информацией -->
        <div class="result-container">
            <!-- Вывод информации -->
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
            <!-- Получение информации и отправка в поля -->
            <?php
            $query = "SELECT * FROM get_abonent_info($number)";
            $result = pg_query($conn, $query);
            if (!$result) {
                echo "Ошибка выполнения запроса.";
            } else {
                $row = pg_fetch_assoc($result);
                echo "<script>
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
            ?>
            <!-- Раскрывающийся список -->
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
            
        </div>  
    </div>
</body>
</html>