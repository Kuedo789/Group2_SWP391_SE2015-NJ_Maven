package com.bakeryzone.model;

public class UnitMeasure {
    private String unitId;
    private String unitName;
    private String description;
    private boolean enable;

    public UnitMeasure() {
    }

    public UnitMeasure(String unitId, String unitName, String description) {
        this.unitId = unitId;
        this.unitName = unitName;
        this.description = description;
        this.enable = true;
    }

    public UnitMeasure(String unitId, String unitName, String description, boolean enable) {
        this.unitId = unitId;
        this.unitName = unitName;
        this.description = description;
        this.enable = enable;
    }

    public String getUnitId() {
        return unitId;
    }

    public void setUnitId(String unitId) {
        this.unitId = unitId;
    }

    public String getUnitName() {
        return unitName;
    }

    public void setUnitName(String unitName) {
        this.unitName = unitName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isEnable() {
        return enable;
    }

    public void setEnable(boolean enable) {
        this.enable = enable;
    }
}
