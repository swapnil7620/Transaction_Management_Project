<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="Style.css">
</head>
<body>
    <div class="login-container">
        <h1>Login</h1>
        <form method="post" action=" ">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required>

            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>

            <button type="submit">Login</button>
        </form>

        <%
            String status = "";
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");

                if (username != null && password != null && !username.isEmpty() && !password.isEmpty()) {
                    Connection connection = null;
                    try {
                        // Database connection details
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/tms", "root", "put your own password");

                        String query = "SELECT * FROM user_login WHERE account_number = ? AND password = ?";
                        PreparedStatement preparedStatement = connection.prepareStatement(query);
                        preparedStatement.setString(1, username);
                        preparedStatement.setString(2, password);
                        ResultSet resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
                            // Redirect to transaction.jsp if credentials are valid
                            response.sendRedirect("transaction.jsp");
                        } else {
                            status = "Invalid Username or Password.";
                        }

                        resultSet.close();
                        preparedStatement.close();
                        connection.close();
                    } catch (Exception exception) {
                        status = "Error: " + exception.getMessage();
                    }
                } else {
                    status = "All fields are required.";
                }
            }
        %>
        <%
            if (!status.isEmpty()) {
        %>
            <p class="status-message"><%= status %></p>
        <%
            }
        %>
    </div>
</body>
</html>
