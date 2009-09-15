package org.sparcs.geoul.monitor.client;

import java.util.List;

import org.sparcs.geoul.monitor.client.data.GeoulPackage;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("status")
public interface StatusService extends RemoteService {
	List<GeoulPackage> getSiteStatus(String geoulURL)
			throws StatusServiceException;
}
