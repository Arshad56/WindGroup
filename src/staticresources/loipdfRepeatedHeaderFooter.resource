@page { 
		margin-top:110px;
		@top-center {
			content: element(header);    
		}        
		@bottom-left {
			content: element(footer);
		}    
	}
	
div.header {
	position: running(header);
}

div.footer {        
	display: block;
	text-align:center;
	position: running(footer);
}

 

.pagenumber:before {
	content: counter(page);
}

.pagecount:before {
	content: counter(pages);
}