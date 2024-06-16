<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Авторизация</title>
    <!-- Локальные стили -->
    <style>
        h1 {
            margin: auto;
            padding: auto;
            text-align: center;
        }
        .container {
            max-width: 400px;
            margin: 50px auto;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 5px 0;
            box-sizing: border-box;
        }
        button {
            
            width: 100%;
            box-sizing: border-box;
        }
    </style>
</head>
<body>
<!-- Контейнер окна входа -->
<div class="container">
    <h1>Вход</h1>
    <!-- Форма с методом пост и перенаправлением на страницу проверки логина -->
    <form method="post" action="login.php">
        <label for="username" form-label mt-4>Имя пользователя:</label>
        <input type="text" id="username" name="username" class="form-control" required>
        <label for="password" form-label mt-4>Пароль:</label>
        <input type="password" id="password" name="password" class="form-control" required>
        <button type="submit" class="btn btn-info">Войти</button>
    </form>
</div>
</body>
</html>
