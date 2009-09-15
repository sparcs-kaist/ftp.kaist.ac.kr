package org.sparcs.geoul.monitor.server;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings("serial")
public class StatusPageServlet extends HttpServlet {
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		resp.setContentType("text/html");
		ServletOutputStream out = resp.getOutputStream();
		FileInputStream in = new FileInputStream(new File("GeoulMon.html"));
		int read;
		byte[] b = new byte[8192];
		while ((read = in.read(b)) != -1)
			out.write(b, 0, read);
		in.close();
		out.close();
	}
}
