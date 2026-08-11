package model;

public class UserStats {
    private int totalUsers;
    private int activeUsers;
    private int inactiveUsers;
    private int staffUsers;

    public int getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(int totalUsers) {
        this.totalUsers = totalUsers;
    }

    public int getActiveUsers() {
        return activeUsers;
    }

    public void setActiveUsers(int activeUsers) {
        this.activeUsers = activeUsers;
    }

    public int getInactiveUsers() {
        return inactiveUsers;
    }

    public void setInactiveUsers(int inactiveUsers) {
        this.inactiveUsers = inactiveUsers;
    }

    public int getStaffUsers() {
        return staffUsers;
    }

    public void setStaffUsers(int staffUsers) {
        this.staffUsers = staffUsers;
    }
}
