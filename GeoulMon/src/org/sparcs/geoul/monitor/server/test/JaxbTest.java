package org.sparcs.geoul.monitor.server.test;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;

import org.apache.tools.ant.filters.StringInputStream;
import org.sparcs.geoul.monitor.client.data.GeoulPackages;

public class JaxbTest {

	public static void main(String[] args) {
		String s1 = "<status>"
				+ "<updated timestamp='2009-09-15' href='success.log'/>"
				+ "<failed timestamp='2009-09-13' href='fail.log'/>"
				+ "<synchronizing timestamp='2009-09-15' href='sync-in-progress.log'/>"
				+ "</status>";
		String p1 = "<package id='foo' name='Foo'>"
				+ "<sync source='origin' frequency='P1D'/>"
				+ "<link rel='a' href='1'/>" + "<link rel='b' href='2'/>" + s1
				+ "</package>";
		String pidx = "<packages>" + p1 + "</packages>";
		try {
			JAXBContext jaxbContext = JAXBContext
					.newInstance(GeoulPackages.class);
			GeoulPackages pi = (GeoulPackages) jaxbContext.createUnmarshaller()
					.unmarshal(new StringInputStream(pidx));
			jaxbContext.createMarshaller().marshal(pi, System.out);
		} catch (JAXBException e) {
			e.printStackTrace();
		}
	}
}
