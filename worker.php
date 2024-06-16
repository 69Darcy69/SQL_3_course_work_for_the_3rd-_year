<?php
session_start(); // Начинаем сессию
// Получаем данные пользователя из сессии
$username = $_SESSION['username'] ?? null;
$password = $_SESSION['password'] ?? null;
$json_data = file_get_contents("worker.json");
$data_array = json_decode($json_data, true);
$id_worker = $data_array[$username] ?? null;
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
    <title>Монтер</title>
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
            width: 90%;
        }
        .form-control {
            text-align: center;
            font-weight: bold;
        }
        .table-primary {
            margin: auto;
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
    <!-- Меню контейнер -->
    <div class="menu-container">
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="input-group mb-3">
                <input type="text" name="id_job" class="form-control" placeholder="Введите ID заявки" required>
                <button class="btn btn-success" name="execute">Отметить выполнение</button>
            </div>
        </form>
        <form method="post">
            <button type="submit" class="btn btn-primary logout-button" name="logout">Выход</button>
        </form>
        <!-- Обработчик кнопки отметки выполнения -->
        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            if (isset($_POST['execute'])) {
                $id_job = $_POST['id_job'];
                $query = "select done_job($id_job)";
                $result = pg_query($conn, $query);
            }
        }
        ?>
    </div>
    <div class="low-container">
        <!-- Контейнер со списком работ -->
        <div class="result-container">
            <?php
            try {
                $query = "SELECT * FROM get_jobs_worker($id_worker)";
                $result = @pg_query($conn, $query);
                if (!$result) {
                    echo "Ошибка выполнения запроса";
                } else {
                    // Вывод результатов запроса в таблицу
                    echo "<table class='table-primary'>";
                    $row = @pg_fetch_assoc($result);
                    if (is_array($row)) {
                        echo "<tr>";
                        foreach ($row as $column_name => $value) {
                            echo "<th>" . $column_name . "</th>";
                        }
                    }
                    echo "</tr>";
                    // Вывод данных таблицы
                    @pg_result_seek($result, 0);
                    while ($row = @pg_fetch_assoc($result)) {
                        echo "<tr>";
                        foreach ($row as $value) {
                            echo "<td>" . $value . "</td>";
                        }
                        echo "</tr>";
                    }
                    echo "</table>";
                }
            } catch (Throwable $e) {
                echo "Работы отсутствуют!";
            }
            ?> 
        </div> 
    </div>
</body>
</html>