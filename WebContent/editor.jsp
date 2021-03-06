<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="uk.ac.cam.grpproj.lima.flashmoblearning.database.*, java.sql.*,uk.ac.cam.grpproj.lima.flashmoblearning.*, java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html> 
<head> 

    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="skulpt.min.js" type="text/javascript"></script>
    <script src="skulpt-stdlib.js" type="text/javascript"></script> 
    <script src="codemirror.js"></script>
    <link rel="stylesheet" href="css/codemirror.css">
    <script src="python.js"></script>
    <link  href="css/demo.css" rel="stylesheet" />

    <!-- Include jQuery.mmenu .css files -->
    <link  href="css/jquery.mmenu.all.css" rel="stylesheet" />

    <!-- Include jQuery and the jQuery.mmenu .js files -->
    <script type="text/javascript" src="jquery-2.1.3.min.js"></script>
    <script type="text/javascript" src="jquery.mmenu.min.all.js"></script>
    
    <script src="jquery.tagsinput.js"></script>
    <script src="jquery-ui.js"></script>
    
	<script src="jquery.taghandler.js"></script>
	<link rel="stylesheet" type="text/css" href="jquery.taghandler.css"/>
    <!-- Fire the plugin onDocumentReady -->
    <script type="text/javascript">
    

	$(function(){
		$('.tagInputField').autocomplete();
	})
	$(document).ready(function(){
		var availableTags = [];
	<%
	DocumentManager dm = DocumentManager.getInstance();
	Set<Tag> tagList = dm.getTagsNotBanned();
	for(Tag t:tagList){
		out.println("availableTags.push('"+HTMLEncoder.encode(t.name)+"');");
	}
	%>
	
	<%
		if(session.getAttribute(Attribute.USERID)==null){
			response.sendRedirect("login.jsp");
			return;
		}
	
		boolean published = false;
		boolean isAdmin = false;
		boolean myDoc = false; 
		
		long uid = (Long) session.getAttribute(Attribute.USERID);
		
		if (session.getAttribute(Attribute.DOCTYPE) == null) {
			response.sendRedirect("landing.jsp");
			return;
		}
		
		String priv = (String) session.getAttribute(Attribute.PRIVILEGE);
		isAdmin = priv != null && priv.equals("admin");
		DocumentType dt = (DocumentType) session.getAttribute(Attribute.DOCTYPE);
		
		
		String newDoc = request.getParameter("newDoc");
		String docID = request.getParameter("docID");
		if(docID==null) {
			response.sendRedirect("error.jsp");
			return;
		}
		if(newDoc==null) { 
			newDoc = "0";
		}
		
		Document document = DocumentManager.getInstance().getDocumentById(Long.parseLong(docID));
		if(document instanceof PublishedDocument) published = true;
		
		myDoc = document.owner.getID() == uid;
		Set<Tag> thisTags = document.getTags();
		%>
		
	var allowEdit;
		<%
    if (published){
    	%>allowEdit = false;<%
    }else{
    %>allowEdit = true;
	<%
    }
	%>
	
	var currentTags = [];
	<%
	for(Tag t : thisTags) {
		if (!t.getBanned())
			out.println("currentTags.push('"+HTMLEncoder.encode(t.name)+"')");
	}
	%>
	$("#array_tag_handler").tagHandler({
	assignedTags:currentTags,
    availableTags: availableTags,
    autocomplete: true,
    allowEdit : allowEdit
	});
	
    $("#menu").mmenu({
        "slidingSubmenus": false,
        "classes": "mm-white",
        "searchfield":{
       	 add:true,
       	 search:false
        }
     });
    
	$("#menu .mm-search input")
    .bind( "change", function() {
        // do your search

        // maybe close the menu?
        $("#foo").trigger( "close" );
    }
);
	
	

	})
	
	// output functions are configurable.  This one just appends some text
	// to a pre element.

	var mycodemirror;
	var allowEdit;
	<%
	if (published){
		%>allowEdit = false;<%
	}else{
		%>allowEdit = true;
	<%
	}
	%>
	function loadCodeMirror() {

		mycodemirror = CodeMirror.fromTextArea(document
				.getElementById("code"), {
			lineNumbers : true,
			mode : "python",
			lineWrapping:true,
			readOnly:!allowEdit
		});

	}
	setTimeout(function() {
		$('.textbox').css({
			'height' : 'auto'
		});
	}, 50);

	function outf(text) {
		var mypre = document.getElementById("output");
		mypre.innerHTML = mypre.innerHTML + text;
	}
	function builtinRead(x) {
		if (Sk.builtinFiles === undefined
				|| Sk.builtinFiles["files"][x] === undefined)
			throw "File not found: '" + x + "'";
		return Sk.builtinFiles["files"][x];
	}

	// Here's everything you need to run a python program in skulpt
	// grab the code from your textarea
	// get a reference to your pre element for output
	// configure the output function
	// call Sk.importMainWithBody()

	function runit() {
		mycodemirror.save();
		var prog = document.getElementById("code").value;
		var mypre = document.getElementById("output");
		mypre.innerHTML = '';
		Sk.canvas = "mycanvas";
		Sk.pre = "output";
		Sk.configure({
			output : outf,
			read : builtinRead
		});
		try {
			eval(Sk.importMainWithBody("<stdin>", false, prog));
		} catch (e) {
			alert(e.toString())
		}
	}

	function saveit() {//DOES NOT DO TAGS YET. DOES NOT DO TAGS YET. DOES NOT DO TAGS YET.
		   mycodemirror.save();
		   var mytext = encodeURIComponent(document.getElementById("code").value); 
		   var tags = $('#array_tag_handler').tagHandler("getTags");
		   
	       jQuery.ajax({
	            type: "POST",
	            url: "plaintextfunctions.jsp",
	            data: {
	            	
	            	title: encodeURIComponent(document.getElementById('titleBox').value),
	      			funct: "save",
	                docID: <%=docID%>,
	        		text: mytext,
	        		newDoc: <%=newDoc%>,
	        		tags:encodeURIComponent(tags)
	            },
	            dataType: "script"
	        }).done(function( response ) {
				alert("Save successful");
				window.location ="library.jsp";
	        }).fail(function(response) { alert("Error")   ; });
	}


	function publishit(){
	   mycodemirror.save();
	   var mytext = encodeURIComponent(document.getElementById("code").value); 
	   var tags = $('#array_tag_handler').tagHandler("getTags");
        jQuery.ajax({
            type: "POST",
            url: "plaintextfunctions.jsp",
            async: false,
            data: {
            	
            	title: encodeURIComponent(document.getElementById('titleBox').value),
      			funct: "save",
                docID: <%=docID%>,
        		text: mytext,
        		tags:encodeURIComponent(tags)
        		
            },
            dataType: "script"
        }).done(function( response ) {
			window.location ="publish.jsp?docID=<%=docID%>";
        }).fail(function(response) { alert("Error")   ; });
	}

	
	function deleteit() {
	    if (confirm("Are you sure you want to delete this document ? This cannot be undone.") == true) {
	        window.location = "delete.jsp?docID=<%=docID%>";
	    } else {
	    }
	}
	function featureit(){
		window.location ="feature.jsp?docID=<%=docID%>&feature=true";
		alert("Document featured!");
	}

	function unfeaturit(){
		window.location ="feature.jsp?docID=<%=docID%>&feature=false";
		alert("Document unfeatured!");
	}
	
	function cloneit(){
		window.location = "fork.jsp?docID=<%=docID%>";
	}

	
    </script>
    
</head >

<body onload="loadCodeMirror()">
	<script type="text/javascript">

	</script>
	<!-- The page -->
	<div class="page">
		<div class="header">
			<a href="#menu"></a> Code Editor
		</div>
			<div id ="title">
        
        <%
        if (published){
        	%><div id="titleBox" readonly><%=HTMLEncoder.encode(document.getTitle())%></div> <%
        }else{
        %><input type="text" value="<%=HTMLEncoder.encode(document.getTitle())%>"
		    id="titleBox" maxlength="30" placeholder="Title" required ><br>
		<%
        }
		%>

			</div>
			<style> 
				#title{width:10px;margin:auto auto}}
			</style>

		<div class="codeEditor">


	<textarea class="textbox"  id="code" disabled><%
		if(!newDoc.equals("1")){%><%=
			HTMLEncoder.encode(DocumentManager.getInstance().getRevisionContent(document.getLastRevision()))%><%
		}else{%><%="print 'Hello World'"%><%}%></textarea>
			<br />


			<div id="buttons" style="padding-left: 40%; padding-right: 30%;">
				<button class="fml_buttons" type="button" onclick="runit()"
					style="border-style: none; background: #00CC66; color: #ff7865; width:10%; min-width:50px;">Run</button>
				<%//This is horrid, I know... --Jamie--
					if(published){
					%>
						<button class="fml_buttons" type="button" onclick="cloneit()"
								style="border-style: none; background: #ffdfe0; color: #000000; width:10%; min-width:50px;">Clone</button>			
					<%
						if(isAdmin || myDoc){
						%>
							<button class="fml_buttons" type="button" onclick="deleteit()"
									style="border-style: none; background: #ffdfe0; color: #000000; width:10%; min-width:50px;">Delete</button>			
						<%
						}
						if (!myDoc){
						%>
							<button class="fml_buttons" type="button" onclick="upvoteit()"
									style="border-style: none; background: #ffdfe0; color: #000000; width:10%; min-width:50px;">Upvote</button>			
						<%
						}
						if (isAdmin) {
						
							if(((PublishedDocument) document).getFeatured()){
								%>
								<button class="fml_buttons" type="button" onclick="unfeatureit()"
										style="border-style: none; width:15%; min-width:60px;">unfeature</button><%	
							} else {
								%>
								<button class="fml_buttons" type="button" onclick="featureit()"
										style="border-style: none; width:15%; min-width:60px;">feature</button><%
							}
						}
					} else {
						%><button class="fml_buttons" type="button" onclick="publishit()"
								style="border-style: none; background: #ffdfe0; color: #000000; width:10%; min-width:50px;">Publish</button>
						<button class="fml_buttons" type="button" onclick="deleteit()"
								style="border-style: none; background: #ffdfe0; color: #000000; width:10%; min-width:50px;">Delete</button>			
						<button class="fml_buttons" type="button" onclick="saveit()"
								style="border-style: none; background: #00CC66; color: #ff7865; width:10%; min-width:50px;">Save</button>
						
						<%			

						if (!(myDoc||isAdmin)) {
							response.sendRedirect("error.jsp");
							return;
						}
					}
				%>
				
			</div>
			
			<ul id="array_tag_handler" style="list-style-type:none;"></ul>
			<pre id="output"></pre>
			<!-- If you want turtle graphics include a canvas -->
			<canvas id="mycanvas">
			</mycanvas>
		</div>
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
