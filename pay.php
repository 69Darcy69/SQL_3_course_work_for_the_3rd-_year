<?php
session_start(); // Начинаем сессию
// Получаем данные пользователя из сессии
$username = $_SESSION['username'] ?? null;
$password = $_SESSION['password'] ?? null;
$sum_pay = $_SESSION['sum_pay'] ?? null;
$number_pay = $_SESSION['number_pay'] ?? null;
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
// Обработка кнопки назад
if (isset($_POST['back'])) {
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу назад
    header("Location: abonent.php");
    exit();
}
// Обработка кнопки оплатить
if (isset($_POST['pay'])) {
    $query = "SELECT insert_register($number_pay, $sum_pay);";
    $result = pg_query($conn, $query);
    session_write_close();
    pg_close($conn);
    // Перенаправляем на страницу с чеком
    header("Location: check.php");
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
            height: 340px;
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
    </style>
</head>
<body>
    <!-- Контейнер с формой оплаты -->
    <div class="container">
        <p style="margin-top: 10px;">Сумма к оплате: <?php echo $sum_pay?></p>
        <input type="text" class="form-control" placeholder="Номер карты" required>
        <input type="text" class="form-control" style="margin-top: 10px;" placeholder="Имя на карте" required>
        <div class="form-inline" style="margin-top: 10px;" style="margin-bottom: 10px;">
            <input type="text" style="margin-right: 2px;" class="form-control" placeholder="Действие" required>
            <input type="text" style="margin-left: 2px;" class="form-control" placeholder="CVV" required>
        </div>
        <!-- Строка с кнопками -->
        <div class="form-inline" style="margin-top: 10px;" style="margin-bottom: 10px;">
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                <button class="btn btn-outline-danger" name="back">Отмена</button>
            </form>
            <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                <button class="btn btn-outline-success" name="pay">Оплатить</button>
            </form>
        </div>
    </div>  
</body>
</html>