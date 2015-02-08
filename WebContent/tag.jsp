<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="uk.ac.cam.grpproj.lima.flashmoblearning.*,uk.ac.cam.grpproj.lima.flashmoblearning.database.*,java.util.ArrayList"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Tag - Flash Mob Learning</title>
<link rel="stylesheet" type="text/css" href="HubStyle.css">
<%!
	public void jspInit()
	{
		try
		{
			Database.init();
		}
		catch (Exception e)
		{
			System.out.println("<p class='error'>Something went wrong! Try reloading the page.</p>");
			return;
		}
	}
%>
<style>
table {top:200px;}
</style>
</head>
<body>
<%
	String tagName = request.getParameter("name");
	
	String sortType = request.getParameter("sort");
	if (sortType == null ) sortType = "new";
	if (!sortType.equals("new") && !sortType.equals("top")) sortType = "new";
	String capitalisedSortType = sortType.substring(0, 1).toUpperCase() + sortType.substring(1);
	ArrayList<PublishedDocument> thisTagDocuments = null;

	try
	{
		Tag tag = DocumentManager.getInstance().getTag(tagName);
		QueryParam p;
		if (sortType.equals("new"))
		{
			p = new QueryParam(25, 0, QueryParam.SortField.TIME, QueryParam.SortOrder.DESCENDING);
		}
		
		else
		{
			p = new QueryParam(25, 0, QueryParam.SortField.VOTES, QueryParam.SortOrder.DESCENDING);
		}

		thisTagDocuments = (ArrayList<PublishedDocument>) DocumentManager.getInstance().getPublishedByTag(tag, p);
	}
	
	catch (Exception e)
	{
		out.println("<p class='error'>This tag doesn't seem to exist!</p>");
		return;
	}
	
	
%>

	<div id="orderHolder">
		<a href='<%="tag.jsp?name=" + tagName + "&sort=top"%>'><div class="order" id="left">Top</div></a>
		<a href='<%="tag.jsp?name=" + tagName + "&sort=new"%>'><div class="order" id="right">New</div></a>
	</div>

<h1>Tag: <%= tagName %></h1>
<h2><%= capitalisedSortType %> Documents</h2>
<table>
<%
	for (PublishedDocument pd : thisTagDocuments)
	{
		String ageString;
		int ageInHours = (int) ((System.currentTimeMillis() - pd.creationTime)/3600000);
		if (ageInHours < 1) ageString = "Less than an hour ago";
		else if (ageInHours < 2) ageString = "An hour ago";
		else if (ageInHours < 24) ageString = ageInHours + " hours ago";
		else
		{
			int ageInDays = ageInHours / 24;
			ageString = ageInDays + " days ago";
		}
		
		String entry = 
		"<tr class='upperRow'>" + 
		"<td class='upvote'><button name='upvote" + Long.toString(pd.getID()) + "' >UP</button></td>" + //upvote
		//TODO: Replace with upvote sprite
		//TODO: JavaScript to change upvote sprite and increment score locally on upvote.
		"<td class='title'> <a href='preview.jsp?id=" + Long.toString(pd.getID()) + "'>" + pd.getTitle() 		+ "</a></td>" + //title
		"<td class='age'>" + ageString + "</td>" + //age
		"</tr>" + 
		"<tr class='lowerRow'>" +
		"<td id='score" + Long.toString(pd.getID()) + "' class='votes'>" + pd.getVotes()	+ "</td>" + //score
		"<td class='submitter'> <a href='profile.jsp?id=" + Long.toString(pd.owner.getID()) + "'>" + pd.owner.getName() 		+ "</a></td>" + //submitter
		"<td></td>" +
		"</tr>"; 
		
		out.println(entry);
	}
	
%>
</table>

</body>
</html>