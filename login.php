<?php
session_start(); // Начинаем сессию
// Проверяем, были ли отправлены данные формы
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $password = 'postgres';
    $username = 'postgres';
    $host = 'localhost';
    $dbname = 'GTS';
    // подключимся от имени суперпользователя
    $conn = pg_connect("host=$host dbname=$dbname user=$username password=$password");
    // выполним обновление данных
    pg_query($conn, "SELECT update_balance();");
    pg_query($conn, "SELECT update_job();");
    // закроем подключение
    pg_close($conn);
    // Получаем данные из формы
    $username = $_POST['username'];
    $password = $_POST['password'];
    // подключимся от имени пользвоателя
    $conn = pg_connect("host=$host dbname=$dbname user=$username password=$password");
    if ($conn === false) {  //если подключение не удалось
        header("Location: errorlogin.html");
        exit();
    } else { // если удалось
        // получаем  информацию из json файлов
        $jsonFile = 'operator.json';
        $jsonData = file_get_contents($jsonFile);
        $operatorData = json_decode($jsonData, true);
        $jsonFile = 'worker.json';
        $jsonData = file_get_contents($jsonFile);
        $workerData = json_decode($jsonData, true);
        $jsonFile = 'abonent.json';
        $jsonData = file_get_contents($jsonFile);
        $abonentData = json_decode($jsonData, true);
        $jsonFile = 'reg.json';
        $jsonData = file_get_contents($jsonFile);
        $regData = json_decode($jsonData, true);
        pg_close($conn);
        // поиск нужной страницы для открытия
        if (array_key_exists($username, $operatorData)) { // если оператор
            // поместим в сессию
            $_SESSION['username'] = $username;
            $_SESSION['password'] = $password;
            // закроем сессию на запись
            session_write_close();
            // перенаправим на нужную страницу
            header("Location: operator.php");
            // прервем выполнение скрипта
            exit();
        } else if (array_key_exists($username, $workerData)) { // если монтер
            $_SESSION['username'] = $username;
            $_SESSION['password'] = $password;
            session_write_close();
            header("Location: worker.php");
            exit();
        } else if (array_key_exists($username, $abonentData)) { // если абонент
            $_SESSION['username'] = $username;
            $_SESSION['password'] = $password;
            session_write_close();
            header("Location: abonent.php");
            exit();
        } else if (array_key_exists($username, $regData)) { // если регистратор
            $_SESSION['username'] = $username;
            $_SESSION['password'] = $password;
            session_write_close();
            header("Location: manadger.php");
            exit();
        } else if ($username == 'postgres') { // если админ
            $_SESSION['username'] = $username;
            $_SESSION['password'] = $password;
            session_write_close();
            header("Location: adminpanel.php");
            exit();
        } else { // если пользователь не существует
            pg_close($conn);
            header("Location: errorlogin.html");
            exit(); 
        }
    }
}
?>
