<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%! 
    private String executeTransaction(HttpServletRequest request) {
        String status = "";
        try {
            String debitAccountStr = request.getParameter("debitAccount");
            String creditAccountStr = request.getParameter("creditAccount");
            String amountStr = request.getParameter("amount");

            if (debitAccountStr == null || creditAccountStr == null || amountStr == null ||
                debitAccountStr.isEmpty() || creditAccountStr.isEmpty() || amountStr.isEmpty()) {
                return "";
            }

            int debAccountNumber = Integer.parseInt(debitAccountStr);
            int creAccountNumber = Integer.parseInt(creditAccountStr);
            double amount = Double.parseDouble(amountStr);

            String url = "jdbc:mysql://localhost:3306/tms";
            String username = "root";
            String password = "Nice@7620";

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connection = DriverManager.getConnection(url, username, password);
            connection.setAutoCommit(false);

            String debitQuery = "Update transactions SET Balance = Balance - ? Where Account_Number = ?";
            String creditQuery = "Update transactions SET Balance = Balance + ? Where Account_Number = ?";
            PreparedStatement debitPreparedStatement = connection.prepareStatement(debitQuery);
            PreparedStatement creditPreparedStatement = connection.prepareStatement(creditQuery);

            debitPreparedStatement.setDouble(1, amount);
            debitPreparedStatement.setInt(2, debAccountNumber);
            creditPreparedStatement.setDouble(1, amount);
            creditPreparedStatement.setInt(2, creAccountNumber);

            if (isSufficient(connection, debAccountNumber, amount)) {
                debitPreparedStatement.executeUpdate();
                creditPreparedStatement.executeUpdate();
                connection.commit();
                status = "<span class='success'>Transaction Successful!!</span>";
            } else {
                connection.rollback();
                status = "<span class='failure'>Transaction failed!!!</span>";
            }

            debitPreparedStatement.close();
            creditPreparedStatement.close();
            connection.close();

        } catch (Exception ex) {
            status = "Error: " + ex.getMessage();
        }
        return status;
    }

    private boolean isSufficient(Connection connection, int accountNumber, double amount) throws SQLException {
        String query = "Select Balance From transactions Where Account_Number = ?";
        PreparedStatement preparedStatement = connection.prepareStatement(query);
        preparedStatement.setInt(1, accountNumber);
        ResultSet resultSet = preparedStatement.executeQuery();
        if (resultSet.next()) {
            double currentBalance = resultSet.getDouble("Balance");
            resultSet.close();
            return amount > 0 && amount <= currentBalance;
        }
        resultSet.close();
        return false;
    }
%>

<%
    String status = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        status = executeTransaction(request);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Transaction</title>
    <link rel="stylesheet" href="Style.css">
</head>
<body>
    <div class="container">
        <h1>Bank Transaction</h1>
        <form method="post" action="transaction.jsp">
            <label for="debitAccount">Debit Account Number:</label>
            <input type="text" id="debitAccount" name="debitAccount" required>

            <label for="creditAccount">Credit Account Number:</label>
            <input type="text" id="creditAccount" name="creditAccount" required>

            <label for="amount">Amount:</label>
            <input type="number" id="amount" name="amount" required>

            <button type="submit">Execute Transaction</button>
        </form>
        <%
            if (!status.isEmpty()) {
        %>
            <p id="status" class="large-text"><%= status %></p>
        <%
            }
        %>
    </div>

    <script src="app.js"></script>
</body>
</html>
