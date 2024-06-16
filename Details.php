<?php
session_start(); // Начинаем сессию
// Получаем данные пользователя из сессии
$username = $_SESSION['username'] ?? null;
$password = $_SESSION['password'] ?? null;
$query = $_SESSION['query_details'] ?? null;
$number = $_SESSION['number_details'] ?? null;
$flag_int = $_SESSION['flag_int'] ?? null;
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
// Обработчик кнопки назад
if (isset($_POST['back'])) {
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу назад
    if ($flag_int == 'operator') {
        header("Location: operator.php");
    } else if ($flag_int == 'abonent') {
        header("Location: abonent.php");
    } else {
        session_unset();
        session_destroy();
        header("Location: index.php");
    }
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Детализация</title>
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
        .btn-success{
            margin-top: auto;
            margin-bottom: auto;
        }
        .low-container {
            height: 87vh;
            padding: 10px;
            margin: auto;
            overflow: auto;
            display: block; 
            justify-content: center;
            width: 70%;
        }
        .form-control {
            text-align: center;
            font-weight: bold;
        }
        .form-inline {
            display: flex;
            align-items: center;
        }
        .control {
            background: white;
            margin: auto;
        }
        .table-primary {
            margin: auto;
        }
        h2 {
            text-align: center;
        }
        table {
            border: 1px solid black; 
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black; 
        }
    </style>
</head>
<body>
    <div class="menu-container">
        <form method="post">
            <button class="btn btn-primary" name="back">Назад</button>
            <button type="submit" class="btn btn-primary logout-button" name="logout">Выход</button>
        </form>
    </div>
    <!-- Контейнер с отображаемой информацией -->
    <div class="low-container">
        <h2>Детализация</h2>
        <div class = "form-inline">
            <input id="id_phone" type="text" class="control form-control" readonly>
            <input id="fio" type="text" class="control form-control" readonly>
        </div>
        <?php
        $result = pg_query($conn, "SELECT * FROM get_fio($number)");
        $row = pg_fetch_assoc($result);
        echo "<script>
            document.getElementById('id_phone').value = '" . $number . "';
            document.getElementById('fio').value = '" . $row['fio'] . "';
        </script>";
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
        ?>   
    </div>
</body>
</html>