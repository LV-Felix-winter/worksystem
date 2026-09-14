<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% if (!Boolean.TRUE.equals(request.getAttribute("hideFooter"))) { %>
<footer class="foot">
    <span>© 2026 锐聘 · 演示站点，非正式运营主体</span>
    <span>备案号占位 京ICP备00000000号-1</span>
</footer>
<% } %>
<script src="<%= request.getContextPath() %>/common/regions.js"></script>
<script src="<%= request.getContextPath() %>/common/pickers.js"></script>
</body>
</html>
