#include "ClientsControllerTest.h"

void ClientsControllerTest::testFunction1() {
    ClientsController cc;
    cc.registerClient(Client("AA", "v1.0"));
    cc.registerClient(Client("BB", "v2.0"));
    cc.registerClient(Client("CC", "v3.0"));
    cc.registerClient(Client("DD", "v4.0"));
    cc.registerClient(Client("EE", "v5.0"));
    cc.registerClient(Client("FF", "v6.0"));
    cc.registerClient(Client("GG", "v7.0"));
    cc.registerClient(Client("HH", "v8.0"));
    cc.registerClient(Client("II", "v9.0"));
    cc.registerClient(Client("JJ", "v10.1"));
    cc.registerClient(Client("KK", "v11.0"));
    cc.registerClient(Client("LL", "v12.0"));
    cc.registerClient(Client("MM", "v13.0"));
    cc.registerClient(Client("NN", "v14.3"));

    QCOMPARE_(cc.isRegisteredClient("AA"), true);
    QCOMPARE_(cc.isRegisteredClient("BB"), true);
    QCOMPARE_(cc.isRegisteredClient("CC"), true);
    QCOMPARE_(cc.isRegisteredClient("DD"), true);
    QCOMPARE_(cc.isRegisteredClient("EE"), true);
    QCOMPARE_(cc.isRegisteredClient("FF"), true);
    QCOMPARE_(cc.isRegisteredClient("GG"), true);
    QCOMPARE_(cc.isRegisteredClient("HH"), true);
    QCOMPARE_(cc.isRegisteredClient("II"), true);
    QCOMPARE_(cc.isRegisteredClient("JJ"), true);
    QCOMPARE_(cc.isRegisteredClient("KK"), true);
    QCOMPARE_(cc.isRegisteredClient("LL"), true);
    QCOMPARE_(cc.isRegisteredClient("MM"), true);
    QCOMPARE_(cc.isRegisteredClient("NN"), true);

    QCOMPARE_(cc.unregisterClient(Client("AA", "v1.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("BB", "v2.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("CC", "v3.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("DD", "v4.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("EE", "v5.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("FF", "v6.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("GG", "v7.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("HH", "v8.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("II", "v9.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("JJ", "v10.1")), true);
    QCOMPARE_(cc.unregisterClient(Client("KK", "v11.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("LL", "v12.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("MM", "v13.0")), true);
    QCOMPARE_(cc.unregisterClient(Client("NN", "v14.3")), true);

    QCOMPARE_(cc.unregisterClient(Client("AA", "v1.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("BB", "v2.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("CC", "v3.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("DD", "v4.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("EE", "v5.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("FF", "v6.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("GG", "v7.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("HH", "v8.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("II", "v9.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("JJ", "v10.1")), false);
    QCOMPARE_(cc.unregisterClient(Client("KK", "v11.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("LL", "v12.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("MM", "v13.0")), false);
    QCOMPARE_(cc.unregisterClient(Client("NN", "v14.3")), false);

    QCOMPARE_(cc.isRegisteredClient("AA"), false);
    QCOMPARE_(cc.isRegisteredClient("BB"), false);
    QCOMPARE_(cc.isRegisteredClient("CC"), false);
    QCOMPARE_(cc.isRegisteredClient("DD"), false);
    QCOMPARE_(cc.isRegisteredClient("EE"), false);
    QCOMPARE_(cc.isRegisteredClient("FF"), false);
    QCOMPARE_(cc.isRegisteredClient("GG"), false);
    QCOMPARE_(cc.isRegisteredClient("HH"), false);
    QCOMPARE_(cc.isRegisteredClient("II"), false);
    QCOMPARE_(cc.isRegisteredClient("JJ"), false);
    QCOMPARE_(cc.isRegisteredClient("KK"), false);
    QCOMPARE_(cc.isRegisteredClient("LL"), false);
    QCOMPARE_(cc.isRegisteredClient("MM"), false);
    QCOMPARE_(cc.isRegisteredClient("NN"), false);

}