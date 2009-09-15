package org.sparcs.geoul.monitor.client;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sparcs.geoul.monitor.client.data.GeoulPackage;
import org.sparcs.geoul.monitor.client.data.Status;
import org.sparcs.geoul.monitor.client.data.GeoulPackage.Link;
import org.sparcs.geoul.monitor.client.data.GeoulPackage.SyncConfig;
import org.sparcs.geoul.monitor.client.data.Status.Event;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Document;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.Window.Location;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.ComplexPanel;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Hyperlink;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;

public class GeoulMon implements EntryPoint {

	private final StatusServiceAsync statusService = GWT
			.create(StatusService.class);

	private String geoulURL;

	private Map<String, GeoulPackage> packageIndex = new HashMap<String, GeoulPackage>();
	private FlowPanel packageLabelsPanel;
	private SimplePanel packageDetailsPanel;

	public void onModuleLoad() {
		String siteName = Location.getPath().substring("/sites/".length());
		geoulURL = "http://" + siteName + "/geoul/";

		RootPanel.get("siteName").getElement().setInnerText(siteName);
		Document.get().setTitle(siteName + " Status");

		packageLabelsPanel = new FlowPanel();
		packageLabelsPanel.getElement().setId("packageLabels");
		RootPanel.get("dashboard").add(packageLabelsPanel);
		packageDetailsPanel = new SimplePanel();
		packageDetailsPanel.getElement().setId("packageDetails");
		RootPanel.get("dashboard").add(packageDetailsPanel);

		updatePackagesStatus();

		History.addValueChangeHandler(new ValueChangeHandler<String>() {
			public void onValueChange(ValueChangeEvent<String> event) {
				String token = event.getValue();
				handleHistoryItem(token);
			}
		});

		// ComplexPanel updateControls = new HorizontalPanel();
		// updateControls.add(new Label("Update "));
		// final ListBox intervalList = new ListBox();
		// intervalList.addItem("manually", "-1");
		// intervalList.addItem("every 1 minute", "60");
		// intervalList.addItem("every 5 minutes", "300");
		// intervalList.addItem("every 10 minutes", "600");
		// intervalList.addItem("every 30 minutes", "1800");
		// intervalList.addItem("every 1 hour", "3600");
		// updateControls.add(intervalList);
		// Button updateButton = new Button("Apply", new ClickHandler() {
		// public void onClick(ClickEvent event) {
		// int interval = Integer.parseInt(intervalList
		// .getValue(intervalList.getSelectedIndex()));
		// updatePackagesStatus();
		// if (interval > 0) {
		// // TODO schedule additional update
		// }
		// }
		// });
		// updateControls.add(updateButton);
		// RootPanel.get("controls").add(updateControls);

	}

	private void handleHistoryItem(String token) {
		if (token.startsWith("pkgs/")) {
			String pkgId = token.substring("pkgs/".length());
			GeoulPackage pkg = packageIndex.get(pkgId);
			if (pkg != null)
				showPackageDetails(pkg);
		}
	}

	private void updatePackagesStatus() {
		statusService.getSiteStatus(geoulURL,
				new AsyncCallback<List<GeoulPackage>>() {

					public void onFailure(Throwable caught) {
						// TODO show this more politely
						Window.alert(caught.getLocalizedMessage());
					}

					public void onSuccess(List<GeoulPackage> result) {
						// populate dashboard with them
						packageDetailsPanel.clear();
						packageLabelsPanel.clear();
						packageIndex.clear();
						for (GeoulPackage pkg : result) {
							packageIndex.put(pkg.getId(), pkg);
							packageLabelsPanel.add(createPackageLabel(pkg));
						}
						// handle any history item
						handleHistoryItem(History.getToken());
					}
				});
	}

	private Widget createPackageLabel(final GeoulPackage pkg) {
		Hyperlink label = new Hyperlink(pkg.getName(), "pkgs/" + pkg.getId());
		label.addStyleName("packageLabel");
		// TODO addStyleName for freshness: good or bad
		return label;
	}

	private void showPackageDetails(GeoulPackage pkg) {
		// TODO caching details might be better
		Widget details = createPackageDetails(pkg);
		packageDetailsPanel.setWidget(details);
	}

	private Widget createPackageDetails(GeoulPackage pkg) {
		ComplexPanel detailsPanel = new FlowPanel();
		// title
		detailsPanel.add(new HTML("<big>" + pkg.getName() + "</big>"));
		SyncConfig syncConfig = pkg.getSyncConfig();
		if (syncConfig != null) { // sync configuration
			StringBuffer syncConfigHTML = new StringBuffer();
			syncConfigHTML.append("Updates");
			String frequency = syncConfig.getFrequency();
			if (frequency != null) {
				syncConfigHTML.append(" every ");
				// TODO to a human readable period
				syncConfigHTML.append(frequency);
			}
			syncConfigHTML.append(" from ");
			syncConfigHTML.append(syncConfig.getSource());
			syncConfigHTML.append(".");
			detailsPanel.add(new HTML(syncConfigHTML.toString()));
		}
		Status status = pkg.getStatus();
		if (status != null) { // status
			detailsPanel.add(new HTML(generateEventHTML(
					"Current update started ", status.getUpdating(), ".")));
			detailsPanel.add(new HTML(generateEventHTML("Last updated ", status
					.getUpdated(), ".")));
			detailsPanel.add(new HTML(generateEventHTML(
					"Update recently failed ", status.getFailed(), ".")));
		}
		List<Link> links = pkg.getLinks();
		if (!links.isEmpty()) { // links
			StringBuffer linksHTML = new StringBuffer();
			linksHTML.append("<ul>");
			for (Link link : links) {
				linksHTML.append("<li><a href='");
				linksHTML.append(link.getHref());
				linksHTML.append("'>");
				linksHTML.append(link.getRel());
				linksHTML.append("</a></li>");
			}
			linksHTML.append("</ul>");
			detailsPanel.add(new HTML(linksHTML.toString()));
		}
		{ // usage
			Image usageGraph = new Image(geoulURL + "/pkgs/" + pkg.getId()
					+ "/usage.png");
			usageGraph.addStyleName("statisticalGraph");
			detailsPanel.add(usageGraph);
		}
		{ // size
			Image sizeGraph = new Image(geoulURL + "/pkgs/" + pkg.getId()
					+ "/du.png");
			sizeGraph.addStyleName("statisticalGraph");
			detailsPanel.add(sizeGraph);
		}
		return detailsPanel;
	}

	private String generateEventHTML(String prefix, Event event, String suffix) {
		StringBuffer html = new StringBuffer();
		if (event != null && event.getTimestamp() != null) {
			String href = event.getHref();
			if (href != null) {
				html.append("<a href='");
				html.append(href);
				html.append("'>");
			}
			html.append(prefix);
			// TODO use relative time
			html.append("at ");
			html.append(event.getTimestamp());
			html.append(suffix);
			if (href != null) {
				html.append("</a>");
			}
		}
		return html.toString();
	}
}
