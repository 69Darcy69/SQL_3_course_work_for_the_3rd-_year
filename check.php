<?php
session_start(); // Начинаем сессию
// Получаем данные пользователя из сессии
$username = $_SESSION['username'] ?? null;
$password = $_SESSION['password'] ?? null;
$sum_pay = $_SESSION['sum_pay'] ?? null;
$number_pay = $_SESSION['number_pay'] ?? null;
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
// Обработчик кнопки закрыть
if (isset($_POST['back'])) {
    // Уничтожаем сессию
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу абонента
    header("Location: abonent.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Оплата</title>
    <!-- Локальные стили -->
    <style>  
        .container {
            background: white;
            border: 1px solid #ccc;
            border-radius: 10px;
            max-width: 400px;
            margin: 50px auto;
        }
        .form-inline {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        p {
            white-space: nowrap; /* предотвращает перенос текста */
            text-align: center;
            flex: 0 0 28%;
        }
        h2 {
            text-align: center;
        }
    </style>
</head>
<body>
    <!-- Контейнер с текстом извещения -->
    <div class="container">
        <h2 style="margin-top: 10px;">Оплачено</h2>
        <p style="margin-top: 10px;">Внесенная сумма: <?php echo $sum_pay?> р.</p>
        <p style="margin-top: 10px;">Счет зачисления: <?php echo $number_pay?></p>
        <p style="margin-top: 10px;" id="current-date"></p>
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <div class="form-inline">
                <button class="btn btn-outline-success" name="back">Закрыть</button>
            </div>    
        </form> 
        <script>
            // Получаем текущую дату
            const currentDate = new Date();
            // Форматируем дату
            const options = { year: 'numeric', month: 'long', day: 'numeric' };
            const formattedDate = currentDate.toLocaleDateString('ru-RU', options);
            // Отображаем дату в теге <p>
            document.getElementById('current-date').textContent = `Дата пополнения: ${formattedDate}`;
        </script>
    </div>  
</body>
</html>