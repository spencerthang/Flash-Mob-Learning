<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="uk.ac.cam.grpproj.lima.flashmoblearning.database.*, java.util.Date"%>
<%@ page import="uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.*"%>
<%@ page import="uk.ac.cam.grpproj.lima.flashmoblearning.*, java.sql.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"> 
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link type="text/css" href="textpages.css" rel="stylesheet" />

    <!-- Include jQuery.mmenu .css files -->
    <link type="text/css" href="jquery.mmenu.all.css" rel="stylesheet" />

    <!-- Include jQuery and the jQuery.mmenu .js files -->
    <script type="text/javascript" src="jquery.mobile-1.4.5/jquery-2.1.3.min.js"></script>
    <script type="text/javascript" src="jQuery.mmenu-master/src/js/jquery.mmenu.min.all.js"></script>

    <!-- Fire the plugin onDocumentReady -->
    <script type="text/javascript">
       $(document).ready(function() {
          $("#menu").mmenu({
             "slidingSubmenus": false,
             "classes": "mm-white",
             "searchfield": true
          });
       });
    </script>
<%		
		//Session check
	if(session.getAttribute(Attribute.USERID)==null){
		response.sendRedirect("login.jsp");
		return;
	}

	long uid = (Long) session.getAttribute(Attribute.USERID);
	
	if (session.getAttribute(Attribute.DOCTYPE) == null) {
		response.sendRedirect("landing.jsp");
		return;
	}
	DocumentType dt = (DocumentType) session.getAttribute(Attribute.DOCTYPE);

	String documentID = (String) request.getParameter("docID");
	String priv = (String) session.getAttribute(Attribute.PRIVILEGE);
	boolean isAdmin = priv != null && priv.equals("admin");
	LoginManager l = LoginManager.getInstance();
	User u = l.getUser((String) session.getAttribute(Attribute.USERNAME));
	Long docID = Long.parseLong(documentID);
	Document doc = DocumentManager.getInstance().getDocumentById(docID);
	String title = doc.getTitle();
	String pageType = "Preview";
	if (doc instanceof PublishedDocument){
		pageType = "Published";
	} 	
%>
<title><%=title%> - <%=pageType %></title>
</head >

<body>

<script type="text/javascript"> 

function cloneit(){
	window.location = "fork.jsp?docID=<%=documentID%>";
}

function deleteit() {
    if (confirm("Are you sure you want to delete this document ? This cannot be undone.") == true) {
        window.location = "delete.jsp?docID=<%=documentID%>";
    } else {
    }
}

function editit(){
	window.location = "plaintexteditor.jsp?docID=<%=documentID%>&newDoc=0&wipdoc=1";
}

function publishit(){
	window.location ="publish.jsp?docID=<%=documentID%>";
}
function featureit(){
	window.location ="feature.jsp?docID=<%=documentID%>&feature=true";
	alert("Document featured!");
}

function unfeaturit(){
	window.location ="feature.jsp?docID=<%=documentID%>&feature=false";
	alert("Document unfeatured!");
}

//function upvoteit(){
 //<!-- TODO -->
//}

</script>
          <div class="header">
          <a href="#menu"></a>
          Viewer
        </div>

<div>

<h1 id="titlearea">
     <%=doc.getTitle()+" - "+pageType %>
</h1>
<%	boolean hasParent = false;
try{
	String parentTitle=doc.getParentDocument().getTitle();
	hasParent=true;
}catch(Exception e){}%>
<h2 id="parentdoctitle" style="padding-left:10%; color:lightgrey; font-size:small"> <%if(hasParent){%><%="Based on "+ doc.getParentDocument().getTitle() + "."%><%}else%><%=""%></h2>
<p style="white-space:pre-wrap; width:40ex; margin-left:5px; color:black" id="bodyarea"><%= DocumentManager.getInstance().getRevisionContent(doc.getLastRevision()) %>
</p>
<p id="tagarea" style="padding-left:5%; color:black;">
	Tags : <%= doc.getTags() %>
</p>
<!-- TODO : upvote button qnd upvote count -->
</div>

<div id="buttons" style="padding-left: 20%; padding-right: auto;">
	<%if(pageType.equals("Preview")){%>
		<button class="fml_buttons" type="button" onclick="editit()"
			style="border-style: none; width:15%; min-width:60px;">Edit</button>
	
		<button class="fml_buttons" type="button" onclick="publishit()"
			style="border-style: none; width:15%; min-width:60px;">Publish</button>
			
		<button class="fml_buttons" type="button" onclick="deleteit()"
			style="border-style: none; width:15%; min-width:60px;">Delete</button>
	<%
	}else{
		%><button class="fml_buttons" type="button" onclick="cloneit()"
				style="border-style: none; width:15%; min-width:60px;">Clone</button><%
		String myDoc = request.getParameter("myDoc");
		if(myDoc!= null && ((String) myDoc).equals("1")||isAdmin){
			//my document
			%><button class="fml_buttons" type="button" onclick="deleteit()"
					style="border-style: none; width:15%; min-width:60px;">Delete</button><%
		}else{
			%>
			<button class="fml_buttons" type="button" onclick="upvoteit()"
					style="border-style: none; width:15%; min-width:60px;">Upvote</button><%			
		}
		if(isAdmin){
			if(((PublishedDocument) doc).getFeatured()){
				%>
				<button class="fml_buttons" type="button" onclick="unfeatureit()"
						style="border-style: none; width:15%; min-width:60px;">unfeature</button><%	
			} else {
				%>
				<button class="fml_buttons" type="button" onclick="featureit()"
						style="border-style: none; width:15%; min-width:60px;">feature</button><%
			}
		}
	}
	%>
</div>



      <!-- The menu -->
      <nav id="menu">
         <ul>
            <li><a href="landing.jsp">Home</a></li>
            <li><a href="CreateNew.jsp?doctype=<%=(dt==DocumentType.SKULPT?"skulpt":"plaintext")%>">New Document</a></li>
            <li><a href="library.jsp">Library</a></li>
            <li><a href="profile.jsp?id=<%=uid%>">My Published Docs</a></li>
            <li><a href="hub.jsp">Community Hub</a></li>
            <li><a href="results.jsp">Search</a></li>
            <li style="padding-top: 140%;"></li>
            <li><a href="logout.jsp">Logout</a></li>
         </ul>
      </nav>

</body> 
 
</html> 