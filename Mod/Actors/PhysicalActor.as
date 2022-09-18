#include "Actor.as"
#include "Interpolation.as"
#include "Vec3f.as"
#include "Camera.as"
#include "Mouse.as"
#include "Ray.as"
#include "AABB.as"
#include "Collision.as"
#include "ActorModel.as"
#include "PhysicalActorRunAnim.as"

shared class PhysicalActor : Actor, Collision
{
	Vec3f position;
	private Vec3f prevPosition;
	Vec3f interPosition;

	Vec3f rotation;
	private Vec3f prevRotation;
	Vec3f interRotation;

	Vec3f velocity;
	private Vec3f prevVelocity;
	Vec3f interVelocity;

	private AABB@ collider;
	private u8 collisionFlags = 0;

	private ActorModel@ model;

	private Vec3f cameraPosition = Vec3f(0, 1.6f, 0);

	private float acceleration = 0.08f;
	private float friction = 0.3f;
	private float jumpForce = 0.3f;
	private float gravity = -0.04f;

	private CControls@ controls = getControls();
	private Camera@ camera = Camera::getCamera();
	private Mouse@ mouse = Mouse::getMouse();
	private Map@ map = Map::getMap();

	PhysicalActor(u16 id, CPlayer@ player, Vec3f position)
	{
		super(id, player);
		this.position = position;
		this.prevPosition = position;
	}

	u8 getType()
	{
		return EntityType::PhysicalActor;
	}

	void Init()
	{
		SetCollider(AABB(Vec3f(-0.3f, 0, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));

		if (isServer())
		{
			SetCollisionFlags(CollisionFlag::All);
		}

		if (isClient())
		{
			@model = ActorModel("KnightSkin.png");
			model.SetAnimation(PhysicalActorRunAnim(this, model));
		}
	}

	void PreUpdate()
	{
		prevPosition = position;
		prevRotation = rotation;
		prevVelocity = velocity;
	}

	void Update()
	{
		if (player.isMyPlayer())
		{
			// Gravity
			velocity.y += gravity;

			Rotation();
			Movement();

			// Set velocity to zero if low enough
			if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
			if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
			if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

			this.Collision();
			BlockPlacement();
		}
	}

	void PostUpdate()
	{
		if (player.isMyPlayer())
		{
			camera.position = position + cameraPosition;
			camera.rotation = rotation;
		}
	}

	private void Rotation()
	{
		Vec2f mouseVel = mouse.getVelocity();
		rotation += Vec3f(mouseVel.y, mouseVel.x, 0);
		rotation.x = Maths::Clamp(rotation.x, -90, 90);
		rotation.z = Maths::Clamp(rotation.z, -90, 90);
		rotation.y = (rotation.y + 360.0f) % 360.0f;
	}

	private void Movement()
	{
		Vec2f dir;

		if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
		if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
		if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
		if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;

		float len = dir.Length();
		if (len > 0)
		{
			dir /= len; // Normalize
			dir = dir.RotateBy(rotation.y);
		}

		// Jumping
		if (isOnGround() && controls.ActionKeyPressed(AK_ACTION3))
		{
			velocity.y = jumpForce;
		}

		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
	}

	private void Collision()
	{
		if (hasCollider())
		{
			// Move along x axis if no collision occurred
			Vec3f posTemp = position;
			Vec3f velTemp = velocity;
			bool collisionX = CollisionX(this, posTemp, velTemp);
			if (!collisionX)
			{
				position = posTemp;
				velocity = velTemp;
			}

			CollisionZ(this, position, velocity);

			// Check x collision again if a collision occurred initially
			if (collisionX)
			{
				CollisionX(this, position, velocity);
			}

			CollisionY(this, position, velocity);
		}
		else
		{
			position += velocity;
		}
	}

	private void BlockPlacement()
	{
		if (!mouse.isInControl()) return;

		CBlob@ blob = player.getBlob();
		if (blob is null) return;

		// Destroy block
		if (blob.isKeyJustPressed(key_action2))
		{
			Ray ray(position + cameraPosition, rotation.dir());
			RaycastInfo@ raycastInfo;
			if (ray.raycastBlock(10, @raycastInfo))
			{
				Vec3f blockPos = raycastInfo.hitWorldPos;
				map.ClientSetBlock(raycastInfo.hitWorldPos, 0);
				print("Destroyed block at " + blockPos.toString());
			}
		}

		// Place block
		if (blob.isKeyJustPressed(key_action1))
		{
			Ray ray(position + cameraPosition, rotation.dir());
			RaycastInfo@ raycastInfo;
			if (ray.raycastBlock(10, @raycastInfo))
			{
				Vec3f blockPos = raycastInfo.hitWorldPos + raycastInfo.normal;
				if (map.isValidBlock(blockPos) && !map.isVisible(map.getBlock(blockPos)))
				{
					SColor block = SColor(255, 255, 150, 150);
					map.ClientSetBlock(blockPos, block);
					print("Placed block at " + blockPos.toString());
				}
			}
		}
	}

	void Render()
	{
		if (isClient())
		{
			float t = Interpolation::getFrameTime();
			interPosition = prevPosition.lerp(position, t);
			interVelocity = prevVelocity.lerp(velocity, t);
			interRotation = prevRotation.lerpAngle(rotation, t);
		}

		if (player.isMyPlayer())
		{
			GUI::DrawText(interPosition.toString(), Vec2f(10, 10), color_white);
		}
		else
		{
			model.Render();
		}
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		Actor::SerializeTickClient(bs);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		if (!Actor::deserializeTickClient(bs)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		if (!velocity.deserialize(bs)) return false;
		return true;
	}

	void SerializeTick(CBitStream@ bs)
	{
		Actor::SerializeTick(bs);
		bs.write_u8(collisionFlags);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		if (!Actor::deserializeTick(bs)) return false;
		if (!bs.saferead_u8(collisionFlags)) return false;
		return true;
	}

	void SerializeInit(CBitStream@ bs)
	{
		Actor::SerializeInit(bs);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);
		bs.write_u8(collisionFlags);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!Actor::deserializeInit(bs)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		if (!velocity.deserialize(bs)) return false;
		if (!bs.saferead_u8(collisionFlags)) return false;
		return true;
	}

	AABB@ getCollider()
	{
		return collider;
	}

	void SetCollider(AABB@ collider)
	{
		@this.collider = collider;
	}

	bool hasCollider()
	{
		return collider !is null;
	}

	void AddCollisionFlags(u8 flags)
	{
		SetCollisionFlags(collisionFlags | flags);
	}

	void RemoveCollisionFlags(u8 flags)
	{
		SetCollisionFlags(collisionFlags & ~flags);
	}

	void SetCollisionFlags(u8 flags)
	{
		if (collisionFlags == flags) return;

		collisionFlags = flags;
	}

	bool hasCollisionFlags(u8 flags)
	{
		return (collisionFlags & flags) == flags;
	}

	bool isOnGround()
	{
		return (
			hasCollider() &&
			hasCollisionFlags(CollisionFlag::Blocks) &&
			collider.enteringBlock(position, position + Vec3f(0, -0.001f, 0))
		);
	}
}
