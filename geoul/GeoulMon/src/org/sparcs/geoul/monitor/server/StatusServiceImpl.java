package org.sparcs.geoul.monitor.server;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import javax.xml.bind.DataBindingException;
import javax.xml.bind.JAXB;

import org.sparcs.geoul.monitor.client.StatusService;
import org.sparcs.geoul.monitor.client.StatusServiceException;
import org.sparcs.geoul.monitor.client.data.GeoulPackage;
import org.sparcs.geoul.monitor.client.data.GeoulPackages;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;

@SuppressWarnings("serial")
public class StatusServiceImpl extends RemoteServiceServlet implements
		StatusService {
	public List<GeoulPackage> getSiteStatus(String geoulURL)
			throws StatusServiceException {
		InputStream geoulStatusData = null;
		try {
			URL geoulStatusURL = new URL(geoulURL + "/status.xml");
			geoulStatusData = geoulStatusURL.openStream();
			GeoulPackages geoulPackages = JAXB.unmarshal(geoulStatusData,
					GeoulPackages.class);
			return geoulPackages.getPackages();
		} catch (MalformedURLException e) {
			throw new StatusServiceException(
					"Site name is an invalid URL prefix: " + geoulURL, e);
		} catch (IOException e) {
			throw new StatusServiceException(
					"Failed to retreive geoul status data.", e);
		} catch (DataBindingException e) {
			throw new StatusServiceException(
					"Failed to parse geoul status XML data.", e);
		} finally {
			if (geoulStatusData != null)
				try {
					geoulStatusData.close();
				} catch (IOException e) {
				}
		}
	}
}
