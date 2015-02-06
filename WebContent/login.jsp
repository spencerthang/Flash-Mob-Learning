<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Login - Flash Mob Learning</title>
</head>
<body>
	<%	
		if(session.getAttribute("uid")!=null){
			response.sendRedirect("home.jsp");
		}
		String status = request.getParameter("status");
		if(status!=null){
			if(status.equals("fail")){
				%>
					<div><center><font color="red">Either user id or password is wrong.</font></center></div>
				<%
			}
		}
	%>
	<form method="post" action="loginCheck.jsp">
		<center>
			<table border="1" width="30%" cellpadding="3">
				<thead>
					<tr>
						<th colspan="2">Login Here</th>
					</tr>
				</thead>

					<tr>
						<td>User Name</td>
						<td><input type="text" name="id" placeholder="UserID"
							required /></td>
					</tr>
					<tr>
						<td>Password</td>
						<td><input type="password" name="pwd" placeholder="Password"
							required /></td>
					</tr>
					<tr>
						<td><input type="submit" value="Login" /></td>
					</tr>
					<tr>
						<td colspan="2">New user? <a href="reg.jsp">Register Now!</a></td>
					</tr>
				</tbody>
			</table>
		</center>
	</form>
</body>
</html>