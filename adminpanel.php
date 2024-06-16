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
    // Перенаправляем на страницу выхода
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
    <title>Произвольные запросы</title>
    <!-- Локальные стили -->
    <style>
        body {
            display: flex;
            flex-direction: column;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            width: calc(100% - 100px); 
            margin: 20px auto;
        }
        button {
            display: inline-block;
            width: 17%;
        }
        .container textarea {
            width: 100%;
            margin-bottom: 10px;
            padding: 5px;
            font-size: 16px;
            resize: vertical;
        }
        .result-container {
            width: calc(100% - 100px); 
            overflow-x: auto;
        }
        .result-table {
            width: 100%;
        }
        .logout-button:hover {
            background-color: #FF0000;
            color: #FFFFFF; 
        }
    </style>
</head>
<body>
    <!-- Контейнер для ввода запроса -->
    <div class="container">
        <h1>Введите текст запроса:</h1>
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <textarea name="query" rows="5" placeholder="Введите текст запроса"></textarea>
            <div class="button-row">
                <button class= "btn btn-primary button" type="submit" name="execute">Выполнить</button>
                <button class= "btn btn-primary button" type="reset">Очистить</button>
                <button class="btn btn-primary button logout-button" type="submit" name="logout">Выход</button>
            </div>
        </form>
    </div>
    <!-- Контейнер с результатом запроса (при наличии) -->
    <div class="result-container">
        <?php
        // Обработчик для кнопки выполнить
        if (isset($_POST['execute'])) {
            // Получаем текст запроса из поля ввода
            $query = $_POST['query'];
            // Выполняем запрос
            $result = pg_query($conn, $query);
            if (!$result) {
                echo "Ошибка выполнения запроса";
            } else {
                // Выводим результат запроса
                echo "<table class='result-table'>";
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
        ?>
    </div>
</body>
</html>
