/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.model;

/**
 *
 * @author Asus
 */
public class ScreenPermission {

    private String screenId;
    private String screenName;
    private String endpointUrl;
    private boolean isActivated;

    public ScreenPermission() {
    }

    public ScreenPermission(String screenId, String screenName, String endpointUrl, boolean isActivated) {
        this.screenId = screenId;
        this.screenName = screenName;
        this.endpointUrl = endpointUrl;
        this.isActivated = isActivated;
    }

    public String getScreenId() {
        return screenId;
    }

    public void setScreenId(String screenId) {
        this.screenId = screenId;
    }

    public String getScreenName() {
        return screenName;
    }

    public void setScreenName(String screenName) {
        this.screenName = screenName;
    }

    public String getEndpointUrl() {
        return endpointUrl;
    }

    public void setEndpointUrl(String endpointUrl) {
        this.endpointUrl = endpointUrl;
    }

    public boolean isActivated() {
        return isActivated;
    }

    public boolean getActivated() {
        return isActivated;
    }

    public void setActivated(boolean isActivated) {
        this.isActivated = isActivated;
    }

}
