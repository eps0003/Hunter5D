#include "Loading.as"
#include "Config.as"

shared class Mouse
{
	private Vec2f velocity;

	private bool wasInControl = false;

	private CControls@ controls = getControls();
	private Driver@ driver = getDriver();
	private CHUD@ hud = getHUD();
	private LoadingManager@ loadingManager = Loading::getManager();
	private ConfigFile@ cfg = Config::getConfig();

	Vec2f getVelocity()
	{
		return velocity;
	}

	float getSensitivity()
	{
		return cfg.read_f32("sensitivity", 1.0f);
	}

	void SetSensitivity(float sens)
	{
		cfg.add_f32("sensitivity", sens);
		Config::SaveConfig(cfg);
	}

	bool isInControl()
	{
		return !isVisible() && loadingManager.isMyPlayerLoaded();
	}

	bool isVisible()
	{
		return Menu::getMainMenu() !is null || hud.hasMenus() || Engine::hasStandardGUIFocus() || !isWindowFocused();
	}

	void CalculateVelocity()
	{
		Vec2f mousePos = controls.getMouseScreenPos();
		Vec2f center = driver.getScreenCenterPos();

		velocity = Vec2f_zero;

		if (isInControl())
		{
			// Calculate velocity
			if (wasInControl)
			{
				velocity = center - mousePos - Vec2f(5, 5);
				velocity *= getSensitivity() * 0.15f;
			}

			// Recenter mouse
			if (!wasInControl || velocity.LengthSquared() > 0)
			{
				controls.setMousePosition(center);
			}
		}

		wasInControl = isInControl();
	}

	void UpdateVisibility()
	{
		if (isVisible())
		{
			hud.ShowCursor();
		}
		else
		{
			hud.HideCursor();
		}
	}
}

namespace Mouse
{
	shared Mouse@ getMouse()
	{
		Mouse@ mouse;
		if (!getRules().get("mouse", @mouse) && isClient())
		{
			@mouse = Mouse();
			getRules().set("mouse", @mouse);
		}
		return mouse;
	}
}
