package org.sparcs.geoul.monitor.client;

import java.util.List;

import org.sparcs.geoul.monitor.client.data.GeoulPackage;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface StatusServiceAsync {
	void getSiteStatus(String geoulURL,
			AsyncCallback<List<GeoulPackage>> callback);
}
